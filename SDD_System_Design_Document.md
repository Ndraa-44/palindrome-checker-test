# System Design Document (SDD)
## Aplikasi Mobile – Palindrome Checker & User List (Flutter)

**Versi:** 1.1
**Arsitektur:** **Clean Architecture (Feature-Based)**
**State Management:** **Bloc (flutter_bloc)**
**Dependency Injection:** **GetIt**

---

## 1. Arsitektur Umum (Clean Architecture)

Aplikasi ini mengadopsi pola **Clean Architecture** yang berbasis fitur (Feature-Based) untuk menjaga *Separation of Concerns*, *scalability*, dan *testability*.

```text
lib/
├── core/
│   ├── constants/               # API keys, base URL
│   ├── theme/                   # Colors, text styles
│   └── utils/                   # Palindrome checker logic
├── features/
│   ├── session/                 # Feature: Nama User & Selected User (Screen 1 & 2)
│   │   └── presentation/
│   │       ├── bloc/            # SessionBloc
│   │       └── pages/           # HomeScreen, WelcomeScreen
│   └── users/                   # Feature: Fetch User List (Screen 3)
│       ├── domain/
│       │   ├── entities/        # Core business objects
│       │   ├── repositories/    # Interfaces / contracts
│       │   └── usecases/        # Business logic (GetUsers)
│       ├── data/
│       │   ├── models/          # DTOs (Data Transfer Objects)
│       │   ├── datasources/     # API calls (RemoteDataSource)
│       │   └── repositories/    # Implementation dari interfaces domain
│       └── presentation/
│           ├── bloc/            # UserListBloc
│           └── pages/           # UserListScreen
├── shared/
│   └── widgets/                 # Loading indicator, empty/error states
├── injection_container.dart     # GetIt Setup (Dependency Injection)
├── app/
│   └── app.dart                 # MaterialApp, Routes, BlocProviders
└── main.dart                    # Entry point aplikasi
```

---

## 2. Dependency Injection (DI) dengan GetIt

Aplikasi menggunakan `get_it` sebagai jembatan (*Service Locator*) untuk menyuntikkan *dependencies* di setiap layer Clean Architecture (dari Data -> Domain -> Presentation). Konfigurasi terpusat pada file `injection_container.dart`.

```dart
// lib/injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // 1. Presentation (Blocs)
  sl.registerFactory(() => SessionBloc());
  sl.registerFactory(() => UserListBloc(getUsers: sl()));

  // 2. Domain (Use Cases)
  sl.registerLazySingleton(() => GetUsers(sl()));

  // 3. Data (Repositories & Data Sources)
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl()),
  );

  // 4. Core / External
  sl.registerLazySingleton(() => http.Client());
}
```
Setiap *instance* yang dibutuhkan (misal `UserRepository` untuk `GetUsers`) di-*resolve* otomatis oleh `sl()`.

---

## 3. State Management & Data Sharing Antar Screen

Karena requirement mengharuskan:
- Nama dari **Screen 1** dibawa ke **Screen 2**
- User terpilih dari **Screen 3** dikirim balik ke **Screen 2** (tanpa membuat screen baru — cukup pop/kembali)

**Desain:** Menggunakan global **`SessionBloc`** yang di-provide di level `MaterialApp` (`app.dart`) sehingga state-nya persisten selama aplikasi berjalan.

```dart
// session_bloc.dart
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(const SessionState()) {
    on<UpdateName>((event, emit) => emit(state.copyWith(name: event.name)));
    on<UpdateSelectedUser>((event, emit) => emit(state.copyWith(selectedUserName: event.userName)));
  }
}
```

**Alur data lintas screen:**
1. Screen 1 → saat "Next" ditekan → `context.read<SessionBloc>().add(UpdateName(nameController.text))` → `Navigator.pushNamed(context, '/welcome')`
2. Screen 2 → menampilkan UI secara reaktif dengan `BlocBuilder<SessionBloc, SessionState>` untuk membaca `state.name` dan `state.selectedUserName`.
3. Screen 3 → saat item di-tap → `context.read<SessionBloc>().add(UpdateSelectedUser(fullName))` → `Navigator.pop(context)` (kembali ke Screen 2 yang sudah ada di stack, **bukan push screen baru**).

---

## 4. Desain Modul per Fitur

### 4.1 Feature: Session (Screen 1 & 2)
Mengatur *state* lokal (validasi form/dialog) dan global (Nama & Selected User).

**Screen 1 – Palindrome Checker**
- Logika pengecekan palindrome berada di layer `core/utils/` agar bisa di-*reuse* atau di-*test* secara terpisah.
- `isPalindrome(String sentence)` menormalisasi text (lowercase, hapus spasi).

**Screen 2 – Welcome Screen**
- *Stateless Widget* yang sepenuhnya bergantung pada `BlocBuilder<SessionBloc, SessionState>`.

### 4.2 Feature: Users (Screen 3)
Diimplementasikan penuh dengan **Clean Architecture**.

**1. Data Layer (`users/data/`)**
Menangani *fetching* dari API dan konversi JSON ke Model.
```dart
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  // Memanggil GET https://reqres.in/api/users
}
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  // Memanggil remoteDataSource & me-return data ke domain
}
```

**2. Domain Layer (`users/domain/`)**
Tempat Entity dan Business Rules (UseCases) bersemayam, tidak bergantung pada framework Flutter (Pure Dart).
```dart
class GetUsers {
  final UserRepository repository;
  Future<Either<Failure, UserListResponse>> call(int page, int perPage) {
    return repository.getUsers(page: page, perPage: perPage);
  }
}
```

**3. Presentation Layer (`users/presentation/`)**
State dari Screen 3 diatur oleh **`UserListBloc`**.
```dart
class UserListBloc extends Bloc<UserListEvent, UserListState> {
  // State: users (List), page, isLoading, hasMore, errorMessage
  
  // on<FetchUsers> -> Menjalankan GetUsers() untuk halaman pertama
  // on<LoadMoreUsers> -> Menjalankan GetUsers() untuk halaman berikutnya
}
```
View di `UserListScreen` menggunakan `RefreshIndicator` dan memonitor *scroll notification* untuk memicu event `LoadMoreUsers` (Infinite Scroll).

---

## 5. Navigation Design

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

## 6. Error & Edge Case Handling

| Kasus | Penanganan |
|---|---|
| API key invalid / No internet | State Bloc berubah menjadi `UserListError`, UI menampilkan *Error State* + tombol retry |
| Data kosong | State Bloc berubah menjadi `UserListEmpty` (atau array kosong), UI menampilkan `EmptyStateWidget` |
| Sudah di halaman terakhir | Bloc state mendeteksi `hasMore = false`, tidak *trigger* *fetch* API lagi saat di-scroll |
| Input kosong di Screen 1 | Form validasi (*Snackbar* / Error Text) menahan proses Check/Next |

---

## 7. Referensi Library Utama (`pubspec.yaml`)

| Package | Penggunaan |
|---|---|
| `flutter_bloc` & `equatable` | State management dan value comparison (mengurangi *rebuild* berlebih) |
| `get_it` | Dependency Injection (*Service Locator*) |
| `http` | HTTP Client untuk fetching reqres.in |
| `cached_network_image` | Image caching untuk avatar *user* |

---

## 8. Testing Strategy
- **Unit test**: Test logika *pure function* `isPalindrome()`.
- **Bloc test**: Mocking `GetUsers` UseCase menggunakan `mocktail` lalu memverifikasi emisi *state* dari `UserListBloc` (contoh: *Loading* → *Loaded*).
- **Widget test**: Simulasi interaksi form (ketik text) dan tekan tombol untuk memunculkan dialog pada Screen 1.
