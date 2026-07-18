# UI/UX Flow Document
## Aplikasi Mobile – Palindrome Checker & User List

**Versi:** 1.0

---

## 1. Overview Alur Navigasi

```
┌─────────────────┐        Next        ┌──────────────────┐      Choose a User     ┌──────────────────┐
│   SCREEN 1       │ ──────────────────▶ │   SCREEN 2         │ ──────────────────────▶ │   SCREEN 3         │
│  Palindrome       │                     │  Welcome Screen     │                          │  User List          │
│  Checker          │                     │                     │ ◀────────────────────── │                     │
└─────────────────┘                     └──────────────────┘   tap user → pop (return) └──────────────────┘
        │
        │ Check
        ▼
   [Dialog: "isPalindrome" / "not palindrome"]
```

**Prinsip navigasi penting:** Screen 3 tidak pernah membuka screen baru saat user dipilih — ia langsung **pop kembali ke instance Screen 2** yang sudah ada di navigation stack, dengan state `selectedUserName` sudah ter-update melalui shared provider/state.

---

## 2. Screen 1 — Palindrome Checker

### 2.1 Layout (Wireframe Deskripsi)
```
┌───────────────────────────────┐
│         (AppBar - opsional)    │
├───────────────────────────────┤
│  Label: "Name"                 │
│  ┌───────────────────────────┐ │
│  │ [ Input: Name ]            │ │
│  └───────────────────────────┘ │
│                                 │
│  Label: "Sentence"             │
│  ┌───────────────────────────┐ │
│  │ [ Input: Sentence ]        │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │        [ Check ]           │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │        [ Next ]            │ │
│  └───────────────────────────┘ │
└───────────────────────────────┘
```

### 2.2 Interaksi
| Trigger | Aksi | Hasil Visual |
|---|---|---|
| Tap "Check" | Jalankan `isPalindrome(sentence)` | Dialog muncul: **"isPalindrome"** (true) atau **"not palindrome"** (false) |
| Tap "OK" pada dialog | Tutup dialog | Kembali ke Screen 1, input tetap ada |
| Tap "Next" | Simpan `name` ke shared state | Navigasi ke Screen 2 |
| Input kosong + tap Check/Next | Tampilkan validasi error (border merah / snackbar) | Tidak lanjut proses |

### 2.3 States
- **Default**: kedua input kosong, tombol aktif.
- **Filled**: user sudah mengetik.
- **Dialog open**: overlay modal hasil pengecekan.
- **Error**: input kosong ditandai.

---

## 3. Screen 2 — Welcome Screen

### 3.1 Layout (Wireframe Deskripsi)
```
┌───────────────────────────────┐
│         (AppBar - opsional)    │
├───────────────────────────────┤
│                                 │
│         "Welcome"              │   ← label statis, besar/bold
│                                 │
│   Name: {nama dari Screen 1}   │   ← label dinamis
│                                 │
│   Selected User: {nama user}   │   ← label dinamis, awalnya "-" / "Not selected"
│                                 │
│  ┌───────────────────────────┐ │
│  │     [ Choose a User ]      │ │
│  └───────────────────────────┘ │
└───────────────────────────────┘
```

### 3.2 Interaksi
| Trigger | Aksi | Hasil Visual |
|---|---|---|
| Screen dibuka (dari Screen 1) | Baca `name` dari shared state | Label Name terisi |
| Tap "Choose a User" | Push Screen 3 | Navigasi ke Screen 3 |
| Kembali dari Screen 3 (setelah pilih user) | Baca `selectedUserName` dari shared state | Label Selected User ter-update otomatis (reactive) |

### 3.3 States
- **Initial**: Selected User = placeholder ("-" / "Belum dipilih").
- **After selection**: Selected User terisi nama lengkap user.

---

## 4. Screen 3 — User List

### 4.1 Layout (Wireframe Deskripsi)
```
┌───────────────────────────────┐
│  ← (AppBar) "Users"            │
├───────────────────────────────┤
│  ↓ Pull to refresh area        │
│  ┌───────────────────────────┐ │
│  │ [avatar]  George Bluth     │ │
│  │           george@reqres.in │ │
│  ├───────────────────────────┤ │
│  │ [avatar]  Janet Weaver     │ │
│  │           janet@reqres.in  │ │
│  ├───────────────────────────┤ │
│  │           ...              │ │
│  ├───────────────────────────┤ │
│  │     [ loading spinner ]    │ │ ← muncul saat load next page
│  └───────────────────────────┘ │
└───────────────────────────────┘
```

**Empty State:**
```
┌───────────────────────────────┐
│                                 │
│         [ icon empty ]         │
│     "Tidak ada data user"      │
│                                 │
└───────────────────────────────┘
```

**Error State:**
```
┌───────────────────────────────┐
│         [ icon error ]         │
│   "Gagal memuat data"          │
│      [ Coba Lagi ]             │
└───────────────────────────────┘
```

### 4.2 Interaksi
| Trigger | Aksi | Hasil Visual |
|---|---|---|
| Screen dibuka | Fetch page 1 | Loading indicator → list tampil |
| Tarik layar ke bawah (pull) | Refresh dari page 1 | List di-reset & reload |
| Scroll ke bawah list | Fetch page + 1 | Loading spinner kecil di bawah list → item baru ditambahkan |
| Tap salah satu item user | Simpan nama user ke shared state, `pop()` | Kembali ke Screen 2, label Selected User langsung berubah |
| Data kosong | — | Tampilkan Empty State |
| Fetch gagal (network/API key error) | — | Tampilkan Error State + tombol retry |
| Sudah di halaman terakhir | Stop fetch tambahan | Tidak ada spinner tambahan saat scroll |

### 4.3 States
- **Loading (initial)**
- **Loaded (with data)**
- **Loading more (pagination)**
- **Empty**
- **Error**
- **Refreshing**

---

## 5. Ringkasan Shared State Antar Screen

| Data | Dibuat di | Digunakan di | Diupdate di |
|---|---|---|---|
| `name` | Screen 1 (input) | Screen 2 (label) | Screen 1 saat tap "Next" |
| `selectedUserName` | Screen 3 (tap item) | Screen 2 (label) | Screen 3 saat tap item user |

---

## 6. Catatan Desain (jika ada akses Figma)
Karena wireframe asli tersedia di Figma (sesuai instruksi soal), dokumen ini adalah **interpretasi tekstual** dari flow & requirement tertulis. Sebelum development dimulai, disarankan untuk:
1. Login ke Figma yang disediakan, cross-check style (warna, spacing, font) dengan wireframe asli.
2. Ekspor asset (icon, avatar placeholder, empty state illustration) langsung dari Figma jika tersedia.
3. Samakan copy text (label, error message) persis dengan yang ada di prototype Figma bila berbeda dari asumsi di dokumen ini.
