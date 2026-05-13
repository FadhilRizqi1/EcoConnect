<div align="center">

# 🌿 EcoConnect

**A community-driven climate action platform connecting individuals with eco-friendly habits.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Go](https://img.shields.io/badge/Go-1.25+-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://golang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supabase-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://supabase.com)
[![Fiber](https://img.shields.io/badge/Fiber-v2-00ACD7?style=for-the-badge&logo=go&logoColor=white)](https://gofiber.io)
[![Android APK](https://img.shields.io/badge/APK-EcoConnect%201.0.0%2B1-3DDC84?style=for-the-badge&logo=android&logoColor=white)](frontend/build/app/outputs/flutter-apk/EcoConnect.apk)

<br/>

> _"Together for a better earth."_

<br/>

</div>

---

## 📋 Table of Contents

- [✨ About the App](#-about-the-app)
- [🎯 Key Features](#-key-features)
- [🏗️ Architecture & Tech Stack](#️-architecture--tech-stack)
- [📁 Project Structure](#-project-structure)
- [🚀 How to Run](#-how-to-run)
  - [Prerequisites](#prerequisites)
  - [1. Clone & Configure](#1-clone--configure)
  - [2. Database Setup (Supabase)](#2-database-setup-supabase)
  - [3. Run Backend](#3-run-backend)
  - [4. Run Frontend](#4-run-frontend-choose-method)
- [APK Release](#apk-release)
- [🗺️ API Endpoints](#️-api-endpoints)
- [🎨 Design System](#-design-system)
- [🧠 UX Principles Applied](#-ux-principles-applied)
- [📦 Dependencies](#-dependencies)

---

## ✨ About the App

**EcoConnect** is a full-stack application that motivates users to adopt eco-friendly habits through:

- **Gamification 3.0** — Advanced 8-rank progression system, reputation points, badges, and a **dynamic 3D podium leaderboard**.
- **Community Hub** — Category-based community forums with join/leave flow, chat messages, and authentic member counts.
- **Premium Missions** — Specialized high-impact tasks with amber-gradient UI, stronger rewards, and progress-oriented dashboard access.
- **Impact Tracking** — CO₂ savings, action count, points, recent activity, and full historical summaries.
- **Profile & Preferences** — Editable profile, avatar selection, privacy/help sub-pages, and persistent light/dark theme mode.
- **Modern Mobile UI** — Bento dashboard cards, center-docked navigation, polished dark/light themes, and focused mobile ergonomics.

---

## 🎯 Key Features

| Feature                 | Description                                                                                                           |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------- |
| 🔐 **Authentication**   | Register & Login with sophisticated **Dark Gradient** theme                                                           |
| 🏠 **Dashboard**        | Welcome card, rank progress, carbon stats, points, recent activity, joined communities, and premium mission highlight |
| 💎 **Premium Missions** | Distinct high-reward missions with **Amber Gradient** and glow effects                                                |
| ✅ **Action Check-in**  | Stepper input (+/-), real-time reward estimation, and Lucide icons                                                    |
| 📜 **Activity History** | Full log of past actions with carbon/point summaries and notes                                                        |
| 💬 **Community Forum**  | Category-based community list, join/leave flow, member count, and chat messages                                       |
| 🏆 **Leaderboard**      | Top users with **3D Visual Podium** design                                                                            |
| 🌱 **Onboarding**       | Multi-category selection (Hick's Law) with community integration                                                      |
| 👤 **Profile**          | Profile stats, impact chart, badges, avatar picker, editable personal info, privacy, and help pages                   |
| 🌓 **Theme Mode**       | Persistent light/dark mode with dashboard and profile surfaces tuned for both themes                                  |
| 📱 **Android APK**      | Release APK built with the latest splash, onboarding, and dark-mode chat improvements                                 |

---

## 🥇 8-Rank Gamification System

EcoConnect implements a highly balanced, 8-tier progression system to keep users engaged. Every eco-action grants Reputation Points that contribute to level progression:

1. 🌱 **Tunas** (0 pts) - The journey begins here.
2. 🌿 **Bibit** (100 pts) - A sprouting commitment.
3. 🍃 **Daun Hijau** (300 pts) - Growing awareness.
4. 🌳 **Pohon** (700 pts) - Strong foundation.
5. 🛡️ **Pengawal Alam** (1500 pts) - Guarding the ecosystem.
6. 🌍 **Pelindung Bumi** (3000 pts) - Earth's protector.
7. ⚔️ **Ksatria Ekologi** (6000 pts) - Elite green warrior.
8. 👑 **Titan Hijau** (10000 pts) - The ultimate eco-champion.

---

## 🏗️ Architecture & Tech Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    EcoConnect Architecture                  │
│                                                             │
│  ┌──────────────┐        ┌──────────────┐                   │
│  │   Frontend   │  HTTP  │   Backend    │                   │
│  │              │◄──────►│              │                   │
│  │   Flutter    │  JSON  │   Go Fiber   │                   │
│  │   (Web/App)  │        │   REST API   │                   │
│  └──────────────┘        └──────┬───────┘                   │
│                                 │ GORM                      │
│                          ┌──────▼───────┐                   │
│                          │  PostgreSQL  │                   │
│                          │  (Supabase)  │                   │
│                          └──────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

### Backend

| Technology     | Version | Purpose                               |
| -------------- | ------- | ------------------------------------- |
| **Go**         | 1.25+   | Backend programming language          |
| **Fiber v2**   | latest  | HTTP framework (Express-style for Go) |
| **GORM**       | v2      | ORM for PostgreSQL                    |
| **golang-jwt** | v5      | JWT Authentication                    |
| **godotenv**   | latest  | Environment variable management       |
| **bcrypt**     | latest  | Password hashing                      |

### Frontend

| Technology               | Version | Purpose                            |
| ------------------------ | ------- | ---------------------------------- |
| **Flutter**              | 3.x     | UI framework (Mobile focus)        |
| **Dart**                 | 3.x     | Programming language               |
| **go_router**            | ^14.3   | Declarative routing                |
| **http**                 | ^1.2    | Lightweight HTTP client            |
| **lucide_icons**         | latest  | Premium iconography                |
| **confetti**             | ^0.7    | Confetti animation (Peak-End Rule) |
| **flutter_animate**      | ^4.5    | Micro-animations & transitions     |
| **lottie**               | ^3.3.3  | Center action animation            |
| **cached_network_image** | ^3.4    | Remote avatar/image caching        |
| **fl_chart**             | ^0.68   | Profile impact chart               |
| **provider**             | ^6.1    | Theme state management             |
| **intl**                 | ^0.19   | Date & number formatting           |
| **shared_preferences**   | ^2.3    | Local token storage                |
| **google_fonts**         | ^8.1    | Poppins text styling               |
| **flutter_svg**          | ^2.3    | SVG asset support                  |
| **url_launcher**         | ^6.3    | External link handling             |

### Database & Infrastructure

| Technology     | Purpose                                     |
| -------------- | ------------------------------------------- |
| **PostgreSQL** | Relational database                         |
| **Supabase**   | Cloud database hosting + connection pooling |

---

## 📁 Project Structure

```
EcoConnect/
├── 📄 .env                          # Environment variables (DB, JWT, etc.)
│
├── 🗂️ backend/
│   ├── main.go                      # Entry point + seeder
│   ├── go.mod / go.sum
│   ├── config/
│   │   └── database.go              # GORM connection + Supabase config
│   ├── handlers/
│   │   ├── auth.go                  # Register, Login
│   │   ├── action.go                # GetActions, CheckIn
│   │   ├── community.go             # GetCommunities, Chat Messages
│   │   ├── user.go                  # Profile, update profile, leaderboard, history
│   │   └── task.go                  # Legacy task handlers
│   ├── middleware/
│   │   └── auth.go                  # JWT validation middleware
│   ├── models/
│   │   ├── user.go                  # User, Level system
│   │   ├── action.go                # Action, UserActionLog, Community, ChatMessage
│   │   ├── task.go                  # Task, UserTask (legacy)
│   │   └── social.go                # Group, GroupMember, GroupMessage (legacy)
│   ├── routes/
│   │   └── routes.go                # All registered endpoints
│   └── utils/
│       └── jwt.go                   # JWT helper
│
└── 🗂️ frontend/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart                # App entry point
        ├── core/
        │   ├── constants/
        │   │   └── app_constants.dart   # Base URL, categories, keys
        │   ├── router/
        │   │   └── app_router.dart      # GoRouter + auth redirect
        │   └── theme/
        │       ├── app_theme.dart       # Design tokens, colors, gradients
        │       └── theme_provider.dart  # Persistent light/dark theme state
        ├── features/
        │   ├── auth/                    # Login & Register
        │   ├── onboarding/              # Onboarding + category selection
        │   ├── dashboard/               # Home (Bento stats, recent missions)
        │   ├── tasks/                   # Mission List, Check-in & Activity History
        │   ├── communities/             # Community Hub & Chat Forums
        │   ├── leaderboard/             # Leaderboard
        │   └── profile/                 # Profile, privacy, and help center
        ├── services/
        │   ├── api_service.dart         # Centralized HTTP service
        │   └── auth_service.dart        # Token & session management
        └── widgets/
            └── main_shell.dart          # Bottom navigation bar
```

---

## 🚀 How to Run

### Prerequisites

Ensure the following tools are installed on your system:

```bash
# Check Go version (matches go.mod, currently 1.25.x)
go version

# Check Flutter version (minimum 3.x)
flutter --version

# Check Dart version
dart --version

# Check Chrome (for Flutter Web)
google-chrome --version  # or open Chrome manually
```

> 💡 **Install Flutter:** https://docs.flutter.dev/get-started/install  
> 💡 **Install Go:** https://golang.org/dl/

---

### 1. Clone & Configure

```bash
# Clone the repository
git clone https://github.com/FadhilRizqi1/Personal-Project.git
cd Personal-Project/EcoConnect
```

---

### 2. Database Setup (Supabase)

1. Go to [supabase.com](https://supabase.com) → create a new project
2. Navigate to **Settings → Database → Connection Pooling**
3. Select **Transaction** mode and copy the connection string
4. Fill in the details in the `.env` file

> ✅ **No need to create tables manually.** GORM AutoMigrate will automatically create all tables when the backend runs for the first time. Initial seed data (12 actions + 5 communities) will also be populated automatically.

---

### 3. Run Backend

```bash
# Navigate to the backend folder
cd backend

# Download Go dependencies
go mod tidy

# Run the server (will auto-migrate DB & seed data)
go run main.go
```

**Expected output:**

```
✅ Database schema berhasil dimigrasikan
🌱 Data tugas awal berhasil ditambahkan
⚡ Data aksi awal berhasil ditambahkan
🌍 Data komunitas (baru) berhasil ditambahkan
🚀 EcoConnect API berjalan di http://localhost:8080
```

> 💡 Verify backend is running: open http://localhost:8080/health

---

### 4. Run Frontend (Choose Method)

Open a **new terminal** (do not close the backend terminal), navigate to the `frontend/` folder and run `flutter pub get`. After that, choose one of the following methods:

> **API base URL note:** `frontend/lib/core/constants/app_constants.dart` now defaults to the deployed production backend: `https://mafalqi-ecoconnect-backend.hf.space/api`. For local testing, override it with `--dart-define=API_BASE_URL=...`, such as `http://localhost:8080/api` for desktop web, `http://10.0.2.2:8080/api` for Android emulator, or `http://<your-computer-lan-ip>:8080/api` for a physical phone.

#### 💻 Method A: Chrome / Edge Browser (Web)

_Best for quick UI testing without an emulator/device._

```bash
flutter run -d chrome
# or
flutter run -d edge
```

#### 📱 Method B: Android Emulator / iOS Simulator

_Best for testing native mobile experiences._

1. Open Android Studio and launch your AVD (Emulator).
2. Run the command:

```bash
flutter run
```

_(Select your emulator from the list if prompted)._

#### 🔌 Method C: Physical Device (USB Debugging)

_Highly recommended for testing native animation performance._

1. Enable **Developer Options** and **USB Debugging** on your phone.
2. Connect your phone to the PC via a USB cable.
3. Ensure it is detected by running `flutter devices`.
4. Run the application:

```bash
flutter run -d <your-device-id>
```

#### 🛜 Method D: Physical Device via Wi-Fi (Wireless Debugging)

_Best if you prefer testing without cables._

1. Ensure both your PC and phone are connected to the **same Wi-Fi network**.
2. **Android 11+:** Open Developer Options -> **Wireless Debugging** -> "Pair device with pairing code".
3. In your PC terminal, run:

```bash
adb pair <IP_ADDRESS>:<PORT>
```

4. Enter the pairing code from your phone.
5. Connect to the device using the debugging port:

```bash
adb connect <IP_ADDRESS>:<DEBUG_PORT>
```

6. Run the Flutter application:

```bash
flutter run
```

> **🔥 Hot Reload:** While the application is running in the terminal, press **`r`** to instantly see your code changes, or **`R`** to fully restart the application.

---

## APK Release

The current Android release build is available in:

```text
frontend/build/app/outputs/flutter-apk/EcoConnect.apk
```

| APK Info | Value |
| -------- | ----- |
| App name | EcoConnect |
| Version | `1.0.0+1` |
| Build type | Release APK |
| File name | `EcoConnect.apk` |
| File size | `54.3 MB` |
| Last local build | `May 11, 2026 18:54` |
| Default API | `https://mafalqi-ecoconnect-backend.hf.space/api` |

Build the release APK again with:

```bash
cd frontend
flutter build apk --release
```

If you want to generate an APK that points to a local backend, pass `API_BASE_URL` during build:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://<your-computer-lan-ip>:8080/api
```

> For physical Android devices, do not use `localhost` as the API host. Use the computer's LAN IP address so the phone can reach the backend.

Recent APK-related UI updates:

- New branded splash screen with logo, gradient background, visual pattern, and feature chips.
- Onboarding category cards now use Lucide icons instead of plain emoji.
- Register category chips now match the onboarding icon style.
- Community forum chat dark mode contrast has been fixed so input text and chat bubbles stay readable.

---

## 🗺️ API Endpoints

Base URL: `http://localhost:8080/api` for API routes. Health check is available outside the API group at `http://localhost:8080/health`.

### 🔓 Public (No Auth Required)

| Method | Endpoint                       | Description                         |
| ------ | ------------------------------ | ----------------------------------- |
| `POST` | `/auth/daftar`                 | Register new account                |
| `POST` | `/auth/masuk`                  | Login, retrieve JWT token           |
| `GET`  | `http://localhost:8080/health` | Server health check, outside `/api` |

### 🔐 Protected (Requires `Authorization: Bearer <token>`)

| Method | Endpoint                    | Description                                                |
| ------ | --------------------------- | ---------------------------------------------------------- |
| `GET`  | `/actions`                  | List all eco actions (filter: `?kategori=`)                |
| `POST` | `/checkin`                  | Submit green action check-in                               |
| `GET`  | `/profil/:id`               | User profile data                                          |
| `PUT`  | `/profil`                   | Update the logged-in user's name, bio, category, or avatar |
| `GET`  | `/papan-peringkat`          | Top users ranked by points                                 |
| `GET`  | `/riwayat`                  | Full user activity logs with aggregate stats               |
| `GET`  | `/communities`              | List communities (filter: `?kategori=`)                    |
| `POST` | `/communities/:id/join`     | Join or leave a community                                  |
| `GET`  | `/communities/:id/messages` | Community forum messages                                   |
| `POST` | `/communities/:id/messages` | Send message to forum                                      |

### Legacy Compatibility Endpoints

These endpoints are still registered for backward compatibility with older task/group flows:

| Method | Endpoint              | Description                 |
| ------ | --------------------- | --------------------------- |
| `GET`  | `/tugas`              | Legacy task list            |
| `POST` | `/tugas/:id/selesai`  | Complete a legacy task      |
| `GET`  | `/grup`               | Legacy group list           |
| `POST` | `/grup/:id/bergabung` | Join a legacy group         |
| `GET`  | `/grup/:id/pesan`     | Legacy group messages       |
| `POST` | `/grup/:id/pesan`     | Send a legacy group message |

### Example Check-in Request

```json
POST /api/checkin
Authorization: Bearer eyJhbGc...

{
  "action_id": 4,
  "input_value": 12.5,
  "notes": "Cycled from Sudirman to Kuningan"
}
```

### Example Response

```json
{
  "pesan": "Check-in berhasil!",
  "poin_didapat": 125,
  "karbon_dihemat_kg": 2.625,
  "level_baru": "Pohon"
}
```

---

## 🎨 Design System

EcoConnect uses color psychology: **Green (Nature) + Blue (Trust)** with **Amber (Premium)** accents.

| Token              | Color | Hex       | Purpose                      |
| ------------------ | ----- | --------- | ---------------------------- |
| `primaryGreen`     | 🟢    | `#1B6B3A` | Main CTA, active icons       |
| `primaryGreenMint` | 🟩    | `#4FC87A` | Highlights, success states   |
| `primaryBlueMid`   | 🔵    | `#1A73C8` | Info, trust indicators       |
| `accentAmber`      | 🟡    | `#FF8C00` | Premium cards (Von Restorff) |
| `backgroundLight`  | ⬜    | `#F5F9F6` | Main background              |
| `backgroundDark`   | ⚫    | `#0F1F15` | Dark mode background         |
| `cardDark`         | 🟩    | `#243329` | Dark mode card surfaces      |

**Font:** `Poppins` — bundled in `frontend/assets/fonts/` and also supported through `google_fonts` for consistent text styling.

**Theme mode:** The app supports persistent light/dark mode through `ThemeProvider` and `shared_preferences`. Dashboard, profile menus, privacy, and help center screens are tuned so cards, forms, icons, and text stay readable in both themes.

---

## 🧠 UX Principles Applied

The EcoConnect design is built upon proven cognitive principles:

| Principle               | Implementation                                                |
| ----------------------- | ------------------------------------------------------------- |
| **Hick's Law**          | Maximum 5 category choices in onboarding & filters            |
| **Fitts's Law**         | Full-width buttons & **Stepper (+/-)** buttons for easy input |
| **Von Restorff Effect** | **Amber Glow** on premium missions makes them stand out       |
| **Peak-End Rule**       | **Confetti animation** ✨ and snacks after success            |
| **Tesler's Law**        | Point & carbon calculations are done server-side              |
| **Jakob's Law**         | Standard bottom navigation & **Back buttons** in chat/history |
| **Postel's Law**        | Flexible decimal inputs, optional notes, lenient auth flow    |
| **Group Polarization**  | Niche community forums strengthen shared green commitment     |

---

## 📦 Dependencies

### Backend (`go.mod`)

```
github.com/gofiber/fiber/v2
github.com/golang-jwt/jwt/v5
github.com/joho/godotenv
golang.org/x/crypto
gorm.io/gorm
gorm.io/driver/postgres
```

### Frontend (`pubspec.yaml`)

```yaml
dependencies:
  flutter_animate: ^4.5.0
  go_router: ^14.3.0
  http: ^1.2.1
  confetti: ^0.7.0
  provider: ^6.1.2
  shared_preferences: ^2.3.3
  shimmer: ^3.0.0
  lottie: ^3.3.3
  cached_network_image: ^3.4.1
  fl_chart: ^0.68.0
  intl: ^0.19.0
  lucide_icons: ^0.257.0
  google_fonts: ^8.1.0
  url_launcher: ^6.3.1
```

---

## 🤝 Contributing

Pull requests are highly welcome! For major changes, please open an issue first to discuss what you would like to change.

1. Fork this repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'feat: add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

<div align="center">

**Made with 💚 for a better earth**

[![GitHub](https://img.shields.io/badge/GitHub-FadhilRizqi1-181717?style=for-the-badge&logo=github)](https://github.com/FadhilRizqi1)

</div>
