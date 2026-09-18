# NARRATE Flutter App

Aplikasi mobile **NARRATE** adalah aplikasi personal blog berbasis **Flutter** yang digunakan untuk membaca, membuat, mengedit, menyimpan, dan mengelola artikel.

Aplikasi ini terintegrasi dengan **NARRATE Backend REST API** untuk mengambil dan mengelola data artikel, kategori, tag, profil, dan artikel tersimpan.

## Tech Stack

- Flutter
- Dart
- REST API
- HTTP Package
- Image Picker
- Carousel Slider
- Material Design

## Fitur

- Splash Screen
- Login dan Register
- Menampilkan daftar artikel
- Detail artikel
- Kategori artikel
- Membuat artikel
- Mengedit artikel
- Menghapus artikel
- Draft, Published, dan Archived
- Tags berdasarkan kategori
- Membuat tag baru
- Bookmark / Saved Article
- Profile
- Edit Profile
- Upload gambar artikel
- Upload foto profile
- Bottom Navigation

## Navigasi Utama

NARRATE memiliki lima menu utama:

```text
Home
│
├── Category
├── Create Post
├── Saved
└── Profile
```

Bottom Navigation:

```text
0 → Home
1 → Category
2 → Create Post
3 → Saved
4 → Profile
```

## Struktur Project

```text
lib/
├── constants/
├── pages/
├── services/
├── widgets/
└── main.dart
```

### Pages

Beberapa halaman utama:

```text
Splash
Login
Register
Home
Category
Category Detail
Detail Article
Create Post
Edit Post
Saved
Profile
Edit Profile
```

### Services

Komunikasi dengan REST API dipisahkan ke beberapa service:

```text
PostService
CategoryService
TagService
SavedService
ProfileService
```

## REST API Flow

```text
Flutter
   ↓
HTTP Request
   ↓
Express REST API
   ↓
PostgreSQL
   ↓
JSON Response
   ↓
Flutter
   ↓
Data ditampilkan ke Widget
```

## Status Artikel

Artikel memiliki tiga status:

- `draft` — artikel belum dipublikasikan
- `published` — artikel sudah dipublikasikan
- `archived` — artikel diarsipkan

Pada halaman Profile, artikel dibagi menjadi:

```text
Postingan Saya
Draf
Arsip
```

## Tags

Tag terhubung dengan kategori artikel.

Pengguna dapat memilih tag yang sudah tersedia atau membuat tag baru.

Contoh tampilan tag:

```text
#Flutter
#WebDevelopment
#MobileApp
```

Tag ditampilkan menggunakan format hashtag tanpa spasi.

## Image Upload

Upload gambar digunakan pada:

- Create Post
- Edit Post
- Edit Profile

Gambar dipilih menggunakan package `image_picker` kemudian dikirim ke backend menggunakan `multipart/form-data`.

## Menjalankan Project

Pastikan Flutter sudah terinstall.

Cek Flutter:

```bash
flutter doctor
```

Clone repository:

```bash
git clone <repository-url>
```

Masuk ke folder project:

```bash
cd narrate_blog
```

Install dependency:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

Untuk Flutter Web:

```bash
flutter run -d chrome
```

## Backend

Aplikasi membutuhkan **NARRATE Backend API** agar data dapat ditampilkan dan dikelola.

Pastikan URL API pada file service sudah sesuai dengan server backend yang digunakan.

## Catatan

- Login dan Register saat ini digunakan sebagai UI dan validasi form.
- Authentication backend belum digunakan.
- Category bersifat read-only.
- Fitur pencarian saat ini masih berupa tampilan UI.
- Data utama aplikasi berasal dari REST API.

## Author

**NARRATE Blog Project**

Project Aplikasi Blog — Pemrograman Mobile, Pemrograman Web Dinamis, Basis Data, dan Analisis Data.
