# EcoConnect Frontend

Frontend EcoConnect adalah aplikasi Flutter mobile-first untuk menjalankan onboarding, autentikasi, dashboard dampak, check-in aksi ramah lingkungan, komunitas, forum chat, leaderboard, profil, dan pengaturan tema.

## Ringkasan

Project ini memakai Flutter dengan struktur feature-based:

- `lib/core/`: konfigurasi global seperti routing, theme, constants, dan helper.
- `lib/features/`: layar utama aplikasi per domain fitur.
- `lib/services/`: akses API dan session/token storage.
- `lib/widgets/`: widget lintas fitur, termasuk shell navigasi bawah.
- `assets/`: gambar, font, icon, dan animasi.

## Fitur UI

- Splash screen dengan branding EcoConnect.
- Onboarding kategori dengan ikon, kartu visual, dan pilihan multi-select.
- Login dan register dengan tampilan glass/dark gradient.
- Dashboard dengan kartu dampak, progres level, misi premium, komunitas, dan aktivitas terakhir.
- Check-in aksi dengan kategori, input satuan, estimasi reward, dan riwayat aktivitas.
- Komunitas dengan join/leave dan forum diskusi.
- Forum chat yang sudah mendukung kontras dark mode.
- Leaderboard dengan layout podium.
- Profil pengguna, avatar picker, edit profil, privasi, bantuan, dan theme mode.

## Tech Stack

- Flutter 3.x
- Dart 3.x
- go_router
- provider
- http
- shared_preferences
- lucide_icons
- cached_network_image
- flutter_animate
- lottie
- confetti
- shimmer
- fl_chart
- intl
- url_launcher

## Struktur Folder Penting

```text
frontend/
|-- pubspec.yaml
|-- assets/
|   |-- fonts/
|   `-- images/
|-- lib/
|   |-- main.dart
|   |-- core/
|   |   |-- constants/app_constants.dart
|   |   |-- router/app_router.dart
|   |   |-- theme/app_theme.dart
|   |   |-- theme/theme_provider.dart
|   |   `-- utils/rank_helper.dart
|   |-- features/
|   |   |-- auth/
|   |   |-- onboarding/
|   |   |-- dashboard/
|   |   |-- tasks/
|   |   |-- communities/
|   |   |-- leaderboard/
|   |   `-- profile/
|   |-- services/
|   |   |-- api_service.dart
|   |   `-- auth_service.dart
|   `-- widgets/main_shell.dart
|-- android/
|-- ios/
|-- web/
|-- windows/
|-- linux/
`-- macos/
```

## Konfigurasi API

Base URL API berada di:

```text
lib/core/constants/app_constants.dart
```

Default production:

```text
https://mafalqi-ecoconnect-backend.hf.space/api
```

Gunakan `--dart-define=API_BASE_URL=...` untuk mengganti target API tanpa mengubah source code.

Contoh:

```bash
# Backend lokal dari Flutter Web/Desktop
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api

# Backend lokal dari Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api

# Backend lokal dari HP fisik di jaringan Wi-Fi yang sama
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8080/api
```

Catatan:

- `localhost` dari Android emulator bukan komputer host, gunakan `10.0.2.2`.
- Untuk HP fisik, backend harus listen di `0.0.0.0` dan firewall Windows harus mengizinkan port backend.

## Menjalankan Aplikasi

Install dependencies:

```bash
flutter pub get
```

Jalankan di device yang tersedia:

```bash
flutter devices
flutter run
```

Jalankan di Chrome:

```bash
flutter run -d chrome
```

Jalankan dengan API lokal:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Build

Build APK release:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/
```

Pada konfigurasi project saat ini, file release yang dipakai adalah:

```text
build/app/outputs/flutter-apk/EcoConnect.apk
```

Build Web:

```bash
flutter build web
```

Output:

```text
build/web/
```

Serve build web lokal untuk pengecekan cepat:

```bash
python -m http.server 3000 --bind 127.0.0.1 --directory build/web
```

Lalu buka:

```text
http://127.0.0.1:3000
```

## Test dan Quality Check

```bash
flutter test
dart format lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
```

Catatan:

- `flutter analyze` tanpa flag non-fatal masih menampilkan lint/info lama di repo.
- Beberapa lint lama yang umum muncul: `withOpacity` deprecated, prefer `const`, dan style lint async context.

## Theme dan Asset

Theme utama ada di:

```text
lib/core/theme/app_theme.dart
lib/core/theme/theme_provider.dart
```

Asset yang dipakai:

```text
assets/images/logo_app.png
assets/fonts/Poppins-Regular.ttf
assets/fonts/Poppins-Medium.ttf
assets/fonts/Poppins-SemiBold.ttf
assets/fonts/Poppins-Bold.ttf
```

## Navigasi

Routing utama memakai `go_router` di:

```text
lib/core/router/app_router.dart
```

Route penting:

| Route | Layar |
| --- | --- |
| `/splash` | Splash screen |
| `/onboarding` | Onboarding |
| `/masuk` | Login |
| `/daftar` | Register |
| `/beranda` | Dashboard |
| `/tugas` | Aksi/check-in |
| `/komunitas` | Daftar komunitas |
| `/komunitas/:id` | Forum komunitas |
| `/papan-peringkat` | Leaderboard |
| `/profil` | Profil user |
| `/privasi` | Privacy |
| `/bantuan` | Help center |

## Catatan Rilis UI Terbaru

- Splash screen dibuat lebih kuat secara visual dengan logo, gradient, pattern, dan chip fitur.
- Onboarding tidak lagi memakai emoji besar, diganti kartu kategori dengan ikon Lucide.
- Register mengikuti gaya ikon yang sama pada kategori minat.
- Chat forum dark mode diperbaiki supaya teks input dan bubble tidak hitam di background gelap.
