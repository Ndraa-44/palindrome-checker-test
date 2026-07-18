# Software Requirements Specification (SRS)
## Aplikasi Mobile – Palindrome Checker & User List (Flutter)

**Versi Dokumen:** 1.0
**Platform Target:** Flutter 3.32+ (State Management: Provider / GetX / Bloc)
**Tanggal:** 18 Juli 2026

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini mendefinisikan kebutuhan fungsional dan non-fungsional untuk aplikasi mobile 3 layar yang terdiri dari: pengecekan kalimat palindrome, halaman welcome dengan data terhubung, dan daftar user dari API eksternal (reqres.in).

### 1.2 Ruang Lingkup
Aplikasi terdiri dari:
1. **Screen 1 – Palindrome Checker**: input nama & kalimat, cek palindrome.
2. **Screen 2 – Welcome Screen**: menampilkan nama dari Screen 1 dan nama user terpilih dari Screen 3.
3. **Screen 3 – User List**: daftar user dari API dengan pagination, pull-to-refresh, dan empty state.

### 1.3 Definisi & Singkatan
| Istilah | Keterangan |
|---|---|
| Palindrome | Kalimat/kata yang sama jika dibaca dari depan maupun belakang (mengabaikan spasi, kapitalisasi, dan tanda baca) |
| SRS | Software Requirements Specification |
| SDD | System Design Document |
| API | Application Programming Interface |
| Pull-to-refresh | Gestur menarik layar ke bawah untuk memuat ulang data |
| Infinite scroll | Memuat data halaman berikutnya otomatis saat scroll mencapai akhir list |

### 1.4 Referensi
- API: `https://reqres.in/api/users?page=1&per_page=10`
- Header wajib: `x-api-key: YOUR_API_KEY` (didapat dari dashboard reqres.in setelah registrasi)

---

## 2. Deskripsi Umum

### 2.1 Perspektif Produk
Aplikasi mobile mandiri (standalone), bukan bagian dari sistem yang lebih besar. Berkomunikasi dengan API pihak ketiga (reqres.in) untuk data user.

### 2.2 Karakteristik Pengguna
Pengguna umum yang menggunakan aplikasi mobile — tidak memerlukan pelatihan khusus, UI harus intuitif.

### 2.3 Batasan (Constraints)
- Flutter versi **3.32 atau lebih tinggi**.
- Wajib menggunakan salah satu state management: **Provider, GetX, atau Bloc**.
- API key reqres.in harus disimpan dengan aman (tidak hardcode di repo publik — gunakan `.env` / `--dart-define`).
- Data yang dibawa antar screen (nama dari Screen 1, user terpilih dari Screen 3) harus tetap ada meski berpindah/kembali antar screen tanpa membuat screen baru (sesuai requirement 4.e).

### 2.4 Asumsi
- Koneksi internet tersedia saat mengakses Screen 3.
- reqres.in API key valid dan tidak melebihi rate limit.

---

## 3. Kebutuhan Fungsional

### 3.1 Screen 1 – Palindrome Checker

| ID | Requirement |
|---|---|
| F-1.1 | Sistem harus menyediakan input text untuk **Nama** |
| F-1.2 | Sistem harus menyediakan input text untuk **Kalimat** yang akan dicek |
| F-1.3 | Sistem harus menyediakan tombol **"Check"** di bawah kedua input |
| F-1.4 | Saat tombol Check ditekan, sistem menjalankan fungsi `isPalindrome(sentence)` |
| F-1.5 | Fungsi palindrome harus **case-insensitive** dan **mengabaikan spasi** (lihat contoh di 3.1.1) |
| F-1.6 | Sistem menampilkan **dialog** berisi pesan `"isPalindrome"` jika hasil true, atau `"not palindrome"` jika false |
| F-1.7 | Sistem menyediakan tombol **"Next"** di bawah tombol Check |
| F-1.8 | Saat tombol Next ditekan, sistem berpindah ke Screen 2 sambil membawa nilai input **Nama** |
| F-1.9 | Validasi: jika input nama/kalimat kosong saat Check/Next ditekan, tampilkan pesan error yang sesuai (rekomendasi tambahan, tidak eksplisit di soal namun best practice) |

#### 3.1.1 Contoh Test Case Palindrome
```
isPalindrome("kasur rusak")     -> true
isPalindrome("step on no pets") -> true
isPalindrome("put it up")       -> true
isPalindrome("suitmedia")       -> false
```
**Algoritma:** normalisasi string (lowercase, hapus semua spasi) → bandingkan string dengan reverse-nya.

### 3.2 Screen 2 – Welcome Screen

| ID | Requirement |
|---|---|
| F-2.1 | Menampilkan label statis **"Welcome"** |
| F-2.2 | Menampilkan label dinamis: **Nama** (dari input Screen 1) |
| F-2.3 | Menampilkan label dinamis: **Selected User Name** (awalnya kosong/placeholder, terisi setelah user memilih dari Screen 3) |
| F-2.4 | Menyediakan tombol **"Choose a User"** |
| F-2.5 | Saat tombol ditekan, sistem berpindah ke Screen 3 |

### 3.3 Screen 3 – User List

| ID | Requirement |
|---|---|
| F-3.1 | Menampilkan list/table user berisi: **avatar, first_name, last_name, email** |
| F-3.2 | Data diambil dari `GET https://reqres.in/api/users?page={page}&per_page={per_page}` |
| F-3.3 | Setiap request wajib menyertakan header `x-api-key: YOUR_API_KEY` |
| F-3.4 | Mendukung **pull-to-refresh** (reload dari page 1) |
| F-3.5 | Mendukung **infinite scroll**: saat scroll mencapai bawah list, otomatis load `page + 1` |
| F-3.6 | Menampilkan **empty state** (ilustrasi/teks) jika data kosong |
| F-3.7 | Menampilkan **loading indicator** saat fetch data (initial load & load more) |
| F-3.8 | Menangani **error state** (misal API key invalid / no internet) dengan pesan yang jelas |
| F-3.9 | Saat item user di-tap, sistem **kembali ke Screen 2** (bukan membuat screen baru) dan mengisi label **Selected User Name** dengan `first_name + last_name` dari user yang dipilih |

---

## 4. Kebutuhan Non-Fungsional

| Kategori | Kebutuhan |
|---|---|
| **Compatibility** | Flutter 3.32+, mendukung Android & iOS |
| **Performance** | List rendering harus lazy (ListView.builder), image avatar di-cache |
| **Usability** | Dialog & feedback jelas, tombol memiliki state disabled saat proses loading |
| **Security** | API key tidak boleh di-commit ke version control publik (gunakan `.gitignore` + `--dart-define` atau file `.env` yang di-ignore) |
| **Maintainability** | Kode terstruktur mengikuti clean architecture / separation of concern (lihat SDD) |
| **State Persistence** | Data nama & selected user tetap tersimpan selama session aplikasi berjalan (di memory / state management, tidak wajib persist ke disk kecuali diminta) |

---

## 5. Kebutuhan Antarmuka Eksternal

### 5.1 API Endpoint
```
GET https://reqres.in/api/users?page=1&per_page=10
Headers:
  x-api-key: YOUR_API_KEY
```

### 5.2 Contoh Response (struktur relevan)
```json
{
  "page": 1,
  "per_page": 10,
  "total": 12,
  "total_pages": 2,
  "data": [
    {
      "id": 1,
      "email": "george.bluth@reqres.in",
      "first_name": "George",
      "last_name": "Bluth",
      "avatar": "https://reqres.in/img/faces/1-image.jpg"
    }
  ]
}
```

---

## 6. Kriteria Penerimaan (Acceptance Criteria) Ringkas
- [ ] Palindrome check menghasilkan output benar untuk 4 contoh kasus di atas.
- [ ] Dialog muncul sesuai kondisi true/false.
- [ ] Nama dari Screen 1 tampil di Screen 2.
- [ ] Navigasi Screen 1 → 2 → 3 → kembali ke 2 (bukan screen baru) berjalan mulus.
- [ ] Pull-to-refresh & infinite scroll berfungsi di Screen 3.
- [ ] Empty state tampil saat data kosong.
- [ ] Selected user name di Screen 2 ter-update setelah memilih user.
