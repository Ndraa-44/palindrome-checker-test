# System Design Document (SDD)
## Aplikasi Mobile – Palindrome Checker & User List (Flutter)

**Versi:** 1.0
**State Management Rekomendasi:** **Bloc** (paling scalable & testable untuk async API + shared state antar screen). Alternatif: Provider (lebih ringan/simple) atau GetX (lebih cepat ditulis).
> Dokumen ini pakai contoh dengan **Provider** untuk kesederhanaan penjelasan, tapi arsitektur berlaku sama untuk Bloc/GetX — hanya beda cara "state holder"-nya.

---

## 1. Arsitektur Umum

Menggunakan pendekatan **layered architecture** sederhana (adaptasi Clean Architecture untuk skala kecil):

```
lib/
├── main.dart
├── app/
│   └── app.dart                # MaterialApp, routes, providers root
├── core/
│   ├── constants/               # api_constants.dart (base url, api key)
│   ├── network/                 # dio_client.dart / http_client.dart
│   └── utils/                   # palindrome_checker.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── user_repository.dart # fetch users dari API
├── presentation/
│   ├── screen1_home/
│   │   ├── home_screen.dart
│   │   └── home_provider.dart   # state: name, sentence, dialog result
│   ├── screen2_welcome/
│   │   ├── welcome_screen.dart
│   │   └── welcome_provider.dart # state: name, selectedUserName
│   └── screen3_userlist/
│       ├── user_list_screen.dart
│       └── user_list_provider.dart # state: users, page, isLoading, hasMore, error
└── shared/
    └── widgets/                 # loading_indicator.dart, empty_state.dart
```

---

## 2. State Management & Data Sharing Antar Screen

Karena requirement mengharuskan:
- Nama dari **Screen 1** dibawa ke **Screen 2**
- User terpilih dari **Screen 3** dikirim balik ke **Screen 2** (tanpa membuat screen baru — cukup pop/kembali)

**Desain:** Gunakan **satu shared provider di level atas (app-level)** yang menyimpan state lintas screen, contoh `UserSessionProvider`:

```dart
class UserSessionProvider extends ChangeNotifier {
  String name = '';
  String selectedUserName = '';

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setSelectedUser(String fullName) {
    selectedUserName = fullName;
    notifyListeners();
  }
}
```

Didaftarkan di root `MultiProvider` (`app.dart`) sehingga bisa diakses oleh Screen 1, 2, dan 3 tanpa perlu pass manual lewat constructor / arguments Navigator.

**Alur data:**
1. Screen 1 → saat "Next" ditekan → `context.read<UserSessionProvider>().setName(nameController.text)` → `Navigator.push(WelcomeScreen)`
2. Screen 2 → membaca `context.watch<UserSessionProvider>().name` & `.selectedUserName` langsung (reactive, otomatis update).
3. Screen 3 → saat item di-tap → `context.read<UserSessionProvider>().setSelectedUser(user.fullName)` → `Navigator.pop(context)` (kembali ke Screen 2 yang sudah ada di stack, **bukan push screen baru**).

> Catatan: Ini yang membuat requirement 4.e ("don't create a new screen, just continue the current screen") terpenuhi — Screen 3 di-push di atas Screen 2, lalu saat memilih user, cukup `pop()` kembali ke instance Screen 2 yang sama.

### Alternatif Bloc
Jika pakai Bloc: buat `UserSessionCubit` dengan method `updateName()` dan `updateSelectedUser()`, di-provide di root via `BlocProvider`, lalu Screen 2 pakai `BlocBuilder<UserSessionCubit, UserSessionState>`.

### Alternatif GetX
Gunakan `UserSessionController extends GetxController` dengan `RxString name.obs` dan `selectedUserName.obs`, akses dari mana saja via `Get.find<UserSessionController>()`.

---

## 3. Desain Modul per Screen

### 3.1 Screen 1 – Palindrome Checker
**Provider:** `HomeProvider` (local state, tidak perlu shared)
```dart
class HomeProvider extends ChangeNotifier {
  bool checkPalindrome(String sentence) {
    final normalized = sentence.toLowerCase().replaceAll(' ', '');
    return normalized == normalized.split('').reversed.join('');
  }
}
```
**Widget tree:** `Scaffold > Column [ TextField(name), TextField(sentence), ElevatedButton(Check), ElevatedButton(Next) ]`

**Dialog:**
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    content: Text(isPalindrome ? "isPalindrome" : "not palindrome"),
  ),
);
```

### 3.2 Screen 2 – Welcome Screen
**Consumes:** `UserSessionProvider` (shared, read-only di sini kecuali reset)
**Widget tree:** `Scaffold > Column [ Text("Welcome"), Text(name), Text(selectedUserName), ElevatedButton("Choose a User") ]`

### 3.3 Screen 3 – User List
**Provider:** `UserListProvider` (local, khusus screen ini)

```dart
class UserListProvider extends ChangeNotifier {
  List<UserModel> users = [];
  int page = 1;
  int totalPages = 1;
  bool isLoading = false;
  String? error;

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) { page = 1; users.clear(); }
    isLoading = true;
    notifyListeners();
    try {
      final result = await UserRepository.getUsers(page: page, perPage: 10);
      users.addAll(result.data);
      totalPages = result.totalPages;
      error = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (page < totalPages && !isLoading) {
      page++;
      await fetchUsers();
    }
  }
}
```

**Widget tree:**
```
Scaffold
 > RefreshIndicator(onRefresh: () => fetchUsers(refresh: true))
   > NotificationListener<ScrollNotification> (deteksi scroll bawah -> loadNextPage())
     > users.isEmpty ? EmptyStateWidget() : ListView.builder(...)
```

**Item tap:**
```dart
onTap: () {
  context.read<UserSessionProvider>()
      .setSelectedUser('${user.firstName} ${user.lastName}');
  Navigator.pop(context); // kembali ke Screen 2
}
```

---

## 4. Desain Data Model

```dart
class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    avatar: json['avatar'],
  );
}

class UserListResponse {
  final List<UserModel> data;
  final int page;
  final int totalPages;

  UserListResponse({required this.data, required this.page, required this.totalPages});

  factory UserListResponse.fromJson(Map<String, dynamic> json) => UserListResponse(
    data: (json['data'] as List).map((e) => UserModel.fromJson(e)).toList(),
    page: json['page'],
    totalPages: json['total_pages'],
  );
}
```

---

## 5. Desain API Layer

```dart
class UserRepository {
  static const _baseUrl = 'https://reqres.in/api/users';
  static const _apiKey = String.fromEnvironment('REQRES_API_KEY'); // via --dart-define

  static Future<UserListResponse> getUsers({required int page, required int perPage}) async {
    final uri = Uri.parse('$_baseUrl?page=$page&per_page=$perPage');
    final response = await http.get(uri, headers: {
      'x-api-key': _apiKey,
    });
    if (response.statusCode == 200) {
      return UserListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }
}
```

**Menjalankan dengan API key aman:**
```
flutter run --dart-define=REQRES_API_KEY=your_actual_key_here
```

---

## 6. Navigation Design

```dart
// app.dart
routes: {
  '/': (_) => const HomeScreen(),
  '/welcome': (_) => const WelcomeScreen(),
  '/users': (_) => const UserListScreen(),
}
```

**Flow:**
```
HomeScreen --(Next, push)--> WelcomeScreen --(Choose a User, push)--> UserListScreen
                                    ^                                        |
                                    |______________(pop, on user tap)_______|
```

---

## 7. Error & Edge Case Handling

| Kasus | Penanganan |
|---|---|
| API key invalid | Tampilkan pesan error di list + tombol retry |
| Tidak ada internet | Tampilkan pesan error + retry |
| Data kosong (empty state) | Ilustrasi/icon + teks "Tidak ada data user" |
| Sudah di halaman terakhir (totalPages tercapai) | Stop infinite scroll, tidak fetch lagi |
| Input kosong di Screen 1 | Validasi sebelum proses Check/Next |

---

## 8. Rekomendasi Library

| Kebutuhan | Package |
|---|---|
| HTTP client | `http` atau `dio` |
| State management | `provider` / `flutter_bloc` / `get` |
| Pull to refresh | Built-in `RefreshIndicator` |
| Image caching (avatar) | `cached_network_image` |
| Env variable / API key | `--dart-define` atau package `flutter_dotenv` |

---

## 9. Testing Strategy (Ringkas)
- **Unit test**: fungsi `isPalindrome()` dengan 4 test case dari SRS.
- **Widget test**: dialog muncul sesuai hasil check.
- **Integration test**: alur navigasi Screen1 → 2 → 3 → kembali ke 2 dengan data terisi benar.
