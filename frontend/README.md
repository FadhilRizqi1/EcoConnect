# EcoConnect Frontend

Flutter mobile-first frontend for EcoConnect, a climate-action habit app with gamified missions, community forums, profile progress, and persistent light/dark theme mode.

## Main Screens

- Onboarding, login, and registration
- Dashboard with rank progress, impact stats, premium mission highlight, joined communities, and recent activity
- Aksi Hijau check-in flow with category tabs, reward estimation, and activity history
- Komunitas list and chat screens
- Papan Peringkat with 3D podium layout
- Profile, avatar picker, edit profile sheet, privacy page, and help center

## Local API

The API base URL is configured in:

```text
lib/core/constants/app_constants.dart
```

It currently points to a LAN backend address so a physical device can reach the Go API. Adjust `baseUrl` for your environment:

- Desktop web: `http://localhost:8080/api`
- Android emulator: `http://10.0.2.2:8080/api`
- Physical phone: `http://<your-computer-lan-ip>:8080/api`

## Run

```bash
flutter pub get
flutter run
```

See the root `README.md` for full backend, Supabase, and API setup instructions.
