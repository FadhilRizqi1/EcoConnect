<div align="center">

# 🌿 EcoConnect

**A community-driven climate action platform connecting individuals with eco-friendly habits.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://golang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supabase-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://supabase.com)
[![Fiber](https://img.shields.io/badge/Fiber-v2-00ACD7?style=for-the-badge&logo=go&logoColor=white)](https://gofiber.io)

<br/>

> _"Together for a better earth."_

<br/>

![EcoConnect Banner](https://img.shields.io/badge/🌍_Carbon_Tracking-✅_Action_Check--in-💬_Community_Chat-1B6B3A?style=flat-square)

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
  - [4. Run Frontend](#4-run-frontend)
- [🗺️ API Endpoints](#️-api-endpoints)
- [🎨 Design System](#-design-system)
- [🧠 UX Principles Applied](#-ux-principles-applied)
- [📦 Dependencies](#-dependencies)

---

## ✨ About the App

**EcoConnect** is a full-stack application that motivates users to adopt eco-friendly habits through:

- **Gamification 2.0** — Reputation points, badges, and a **3D Podium Leaderboard**.
- **Community Hub** — Real-time forums categorized by environmental focus with auto-joining logic.
- **Premium Missions** — Specialized high-impact tasks with exclusive UI and rewards.
- **Impact Tracking** — Detailed history of CO₂ savings and points with rich visual summaries.

---

## 🎯 Key Features

| Feature | Description | Status |
|---------|-------------|--------|
| 🔐 **Authentication** | Register & Login with sophisticated **Dark Gradient** theme | ✅ |
| 🏠 **Dashboard** | Carbon stats, points, actions + recent activities in bento-style | ✅ |
| 💎 **Premium Missions** | Distinct high-reward missions with **Amber Gradient** and glow effects | ✅ |
| ✅ **Action Check-in** | Stepper input (+/-), real-time reward estimation, and Lucide icons | ✅ |
| 📜 **Activity History** | Full log of past actions with carbon/point summaries and notes | ✅ |
| 💬 **Community Forum** | Real-time chat per category with auto-join upon onboarding | ✅ |
| 🏆 **Leaderboard** | Top users with **3D Visual Podium** design | ✅ |
| 🌱 **Onboarding** | Multi-category selection (Hick's Law) with community integration | ✅ |

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
| Technology | Version | Purpose |
|------------|---------|---------|
| **Go** | 1.21+ | Backend programming language |
| **Fiber v2** | latest | HTTP framework (Express-style for Go) |
| **GORM** | v2 | ORM for PostgreSQL |
| **golang-jwt** | v5 | JWT Authentication |
| **godotenv** | latest | Environment variable management |
| **bcrypt** | latest | Password hashing |

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.x | UI framework (Mobile focus) |
| **Dart** | 3.x | Programming language |
| **go_router** | ^14.8 | Declarative routing |
| **http** | ^1.2 | Lightweight HTTP client |
| **lucide_icons** | latest | Premium iconography |
| **confetti** | ^0.7 | Confetti animation (Peak-End Rule) |
| **flutter_animate** | ^4.5 | Micro-animations & transitions |
| **intl** | ^0.19 | Date & number formatting |
| **shared_preferences** | ^2.3 | Local token storage |

### Database & Infrastructure
| Technology | Purpose |
|------------|---------|
| **PostgreSQL** | Relational database |
| **Supabase** | Cloud database hosting + connection pooling |

---

## 📁 Project Structure

```
EcoConnect/
├── 📄 .env                          # Environment variables (DB, JWT, etc.)
├── 📄 INSTRUCTION.md                # Development roadmap
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
│   │   ├── profile.go               # GetProfile
│   │   ├── leaderboard.go           # GetLeaderboard
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
        │       └── app_theme.dart       # Design tokens, colors, gradients
        ├── features/
        │   ├── auth/                    # Login & Register
        │   ├── onboarding/              # Onboarding + category selection
        │   ├── dashboard/               # Home (Bento stats, recent missions)
        │   ├── tasks/                   # Mission List, Check-in & Activity History
        │   ├── communities/             # Community Hub & Chat Forums
        │   ├── leaderboard/             # Leaderboard
        │   └── profile/                 # User Profile
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
# Check Go version (minimum 1.21)
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

Create a **`.env`** file in the root `EcoConnect/` folder (alongside the `backend/` and `frontend/` folders):

```env
# ── Database (Supabase PostgreSQL) ────────────────────────────
DB_HOST=aws-0-ap-southeast-1.pooler.supabase.com
DB_PORT=6543
DB_USER=postgres.YOUR_PROJECT_REF
DB_PASSWORD=YOUR_DB_PASSWORD
DB_NAME=postgres

# ── JWT Secret ────────────────────────────────────────────────
JWT_SECRET=change_this_with_a_long_random_secret_key

# ── Server ────────────────────────────────────────────────────
APP_PORT=8080
```

> ⚠️ **Important:** Replace `YOUR_PROJECT_REF` and `YOUR_DB_PASSWORD` with your Supabase credentials.

---

### 2. Database Setup (Supabase)

1. Go to [supabase.com](https://supabase.com) → create a new project
2. Navigate to **Settings → Database → Connection Pooling**
3. Select **Transaction** mode and copy the connection string
4. Fill in the details in the `.env` file as shown above

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

### 4. Run Frontend

Open a **new terminal** (do not close the backend terminal):

```bash
# From EcoConnect/ root, navigate to the frontend folder
cd frontend

# Download Flutter dependencies
flutter pub get

# Run on Chrome (Flutter Web)
flutter run -d chrome

# Alternative: run on Android emulator
flutter run -d android

# Alternative: build for web
flutter build web
```

**Expected output:**
```
Launching lib/main.dart on Chrome in debug mode...
...
🔥 To hot reload changes while running, press "r". 
```

The app will automatically open in the Chrome browser.

---

### 🔄 Development Workflow

```bash
# Terminal 1: Backend (manual auto-reload)
cd backend && go run main.go

# Terminal 2: Frontend (automatic hot reload)
cd frontend && flutter run -d chrome

# Hot reload Flutter when code changes:
# Press 'r' in the Flutter terminal
# Press 'R' for a full hot restart
```

---

## 🗺️ API Endpoints

Base URL: `http://localhost:8080/api`

### 🔓 Public (No Auth Required)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/daftar` | Register new account |
| `POST` | `/auth/masuk` | Login, retrieve JWT token |
| `GET` | `/health` | Server health check |

### 🔐 Protected (Requires `Authorization: Bearer <token>`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/actions` | List all eco actions (filter: `?kategori=`) |
| `POST` | `/checkin` | Submit green action check-in |
| `GET` | `/profil/:id` | User profile data |
| `GET` | `/papan-peringkat` | Top users ranked by points |
| `GET` | `/riwayat` | Full user activity logs with aggregate stats |
| `GET` | `/communities` | List communities (filter: `?kategori=`) |
| `GET` | `/communities/:id/messages` | Community forum messages |
| `POST` | `/communities/:id/messages` | Send message to forum |

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
  "level_baru": "Pejuang Hijau"
}
```

---

## 🎨 Design System

EcoConnect uses color psychology: **Green (Nature) + Blue (Trust)** with **Amber (Premium)** accents.

| Token | Color | Hex | Purpose |
|-------|-------|-----|---------|
| `primaryGreen` | 🟢 | `#1B6B3A` | Main CTA, active icons |
| `primaryGreenMint` | 🟩 | `#4FC87A` | Highlights, success states |
| `primaryBlueMid` | 🔵 | `#1A73C8` | Info, trust indicators |
| `accentAmber` | 🟡 | `#FF8C00` | Premium cards (Von Restorff) |
| `backgroundLight` | ⬜ | `#F4F9F4` | Main background |

**Font:** `Poppins` (Google Fonts) — modern, friendly, easy to read.

---

## 🧠 UX Principles Applied

The EcoConnect design is built upon proven cognitive principles:

| Principle | Implementation |
|-----------|----------------|
| **Hick's Law** | Maximum 5 category choices in onboarding & filters |
| **Fitts's Law** | Full-width buttons & **Stepper (+/-)** buttons for easy input |
| **Von Restorff Effect** | **Amber Glow** on premium missions makes them stand out |
| **Peak-End Rule** | **Confetti animation** ✨ and snacks after success |
| **Tesler's Law** | Point & carbon calculations are done server-side |
| **Jakob's Law** | Standard bottom navigation & **Back buttons** in chat/history |
| **Postel's Law** | Flexible decimal inputs, optional notes, lenient auth flow |
| **Group Polarization** | Niche community forums strengthen shared green commitment |

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
  lottie: ^3.1.0
  intl: ^0.19.0
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
