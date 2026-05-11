# EcoConnect Frontend

EcoConnect Frontend is a mobile-first Flutter application for onboarding, authentication, impact dashboards, eco-action check-ins, communities, forum chat, leaderboards, profiles, and theme settings.

## Overview

This project uses Flutter with a feature-based structure:

- `lib/core/`: global configuration such as routing, theme, constants, and helpers.
- `lib/features/`: main application screens grouped by feature domain.
- `lib/services/`: API access and session/token storage.
- `lib/widgets/`: cross-feature widgets, including the bottom navigation shell.
- `assets/`: images, fonts, icons, and animations.

## UI Features

- Splash screen with EcoConnect branding.
- Category onboarding with icons, visual cards, and multi-select choices.
- Login and registration with a glass/dark gradient look.
- Dashboard with impact cards, level progress, premium missions, communities, and recent activity.
- Action check-ins with categories, unit input, reward estimation, and activity history.
- Communities with join/leave support and discussion forums.
- Forum chat with dark mode contrast support.
- Leaderboard with a podium layout.
- User profile, avatar picker, profile editing, privacy, help, and theme mode.

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

## Important Folder Structure

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

## API Configuration

The API base URL is configured in:

```text
lib/core/constants/app_constants.dart
```

Default production URL:

```text
https://mafalqi-ecoconnect-backend.hf.space/api
```

Use `--dart-define=API_BASE_URL=...` to change the API target without modifying the source code.

Examples:

```bash
# Local backend from Flutter Web/Desktop
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api

# Local backend from the Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api

# Local backend from a physical phone on the same Wi-Fi network
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8080/api
```

Notes:

- `localhost` from the Android emulator is not the host computer; use `10.0.2.2`.
- For a physical phone, the backend must listen on `0.0.0.0`, and Windows Firewall must allow the backend port.

## Running the Application

Install dependencies:

```bash
flutter pub get
```

Run on an available device:

```bash
flutter devices
flutter run
```

Run in Chrome:

```bash
flutter run -d chrome
```

Run with a local API:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Build

Build the release APK:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/
```

In the current project configuration, the release file used is:

```text
build/app/outputs/flutter-apk/EcoConnect.apk
```

Build for Web:

```bash
flutter build web
```

Output:

```text
build/web/
```

Serve the local web build for a quick check:

```bash
python -m http.server 3000 --bind 127.0.0.1 --directory build/web
```

Then open:

```text
http://127.0.0.1:3000
```

## Tests and Quality Checks

```bash
flutter test
dart format lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
```

Notes:

- `flutter analyze` without the non-fatal flags still shows older lint/info messages in the repo.
- Some common older lints include deprecated `withOpacity`, prefer `const`, and async context style lints.

## Theme and Assets

The main theme is located in:

```text
lib/core/theme/app_theme.dart
lib/core/theme/theme_provider.dart
```

Assets used:

```text
assets/images/logo_app.png
assets/fonts/Poppins-Regular.ttf
assets/fonts/Poppins-Medium.ttf
assets/fonts/Poppins-SemiBold.ttf
assets/fonts/Poppins-Bold.ttf
```

## Navigation

The main routing uses `go_router` in:

```text
lib/core/router/app_router.dart
```

Important routes:

| Route | Screen |
| --- | --- |
| `/splash` | Splash screen |
| `/onboarding` | Onboarding |
| `/masuk` | Login |
| `/daftar` | Register |
| `/beranda` | Dashboard |
| `/tugas` | Actions/check-ins |
| `/komunitas` | Community list |
| `/komunitas/:id` | Community forum |
| `/papan-peringkat` | Leaderboard |
| `/profil` | User profile |
| `/privasi` | Privacy |
| `/bantuan` | Help center |

## Latest UI Release Notes

- The splash screen was made visually stronger with a logo, gradient, pattern, and feature chips.
- Onboarding no longer uses large emojis; they were replaced with category cards and Lucide icons.
- Registration follows the same icon style for interest categories.
- Forum chat dark mode was improved so input text and bubbles do not appear black on dark backgrounds.
