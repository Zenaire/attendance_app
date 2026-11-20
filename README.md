# Presensi Digital (attendance_app)

Aplikasi Android pembelajaran untuk mencatat presensi masuk dan pulang pribadi beserta foto. Versi lokal menggunakan SharedPreferences dan penyimpanan foto pada perangkat.

## Menjalankan

1. `flutter doctor`
2. `flutter pub get`
3. `flutter devices`
4. `flutter run`

Selama Firebase belum dikonfigurasi, aplikasi menampilkan layar **"Firebase belum dikonfigurasi"** beserta langkah setup. Jalankan:

```text
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=ID_PROJECT_ANDA
```

File `lib/firebase_options.dart` adalah placeholder dan akan ditimpa oleh FlutterFire CLI.

## Android

Application ID: `com.example.attendance_app`

## Struktur utama

- `lib/models/` — model data presensi dan profil.
- `lib/services/` — auth, presensi lokal, foto, izin, dan adapter Firestore.
- `lib/wrapper/` — pemantauan status autentikasi.
- `lib/screens/auth/` — masuk dan daftar.
- `lib/screens/home/` — presensi harian.
- `lib/screens/history/` — riwayat akun aktif.
- `lib/screens/config_error/` — petunjuk konfigurasi Firebase.

## Batasan

Cakupan hanya akun, presensi masuk/pulang, foto, dan riwayat pribadi. Tidak ada GPS, QR, admin, rekap semua pengguna, penggajian, notifikasi, mode gelap khusus, atau sinkronisasi cloud.

Foto disimpan lokal pada penyimpanan aplikasi. Foto dan catatan akan hilang jika data aplikasi dihapus atau aplikasi dihapus/diinstall ulang.
