# EcoConnect Backend

EcoConnect Backend is a Go-based REST API for authentication, eco-friendly actions, check-ins, profiles, leaderboards, communities, and forum chat.

## Overview

The backend uses:

- Go 1.25
- Fiber v2
- GORM
- PostgreSQL/Supabase
- JWT
- bcrypt
- godotenv

Entry point:

```text
main.go
```

When the application starts, the backend will:

- Load `.env` from the project root (`../.env`).
- Connect to PostgreSQL.
- Run GORM AutoMigrate.
- Seed initial task, action, and community data if they do not exist yet.
- Adjust premium mission points.
- Start the Fiber server.

## Folder Structure

```text
backend/
|-- README.md
|-- main.go
|-- go.mod
|-- go.sum
|-- config/
|   `-- database.go
|-- handlers/
|   |-- action.go
|   |-- auth.go
|   |-- community.go
|   |-- group.go
|   |-- task.go
|   `-- user.go
|-- middleware/
|   `-- auth.go
|-- models/
|   |-- action.go
|   |-- social.go
|   |-- task.go
|   `-- user.go
|-- routes/
|   `-- routes.go
`-- utils/
    `-- helpers.go
```

## Environment

Create a `.env` file in the project root, one level above the `backend/` folder:

```env
DATABASE_URL=postgres://USER:PASSWORD@HOST:PORT/DB_NAME?sslmode=require

# Alternative when not using DATABASE_URL:
DB_HOST=your-db-host
DB_PORT=6543
DB_USER=your-db-user
DB_PASSWORD=your-db-password
DB_NAME=postgres

JWT_SECRET=change_this_with_a_long_random_secret
APP_PORT=8080
```

Port priority:

1. `PORT`
2. `APP_PORT`
3. `7860`

Notes:

- `DATABASE_URL` is prioritized when available.
- If using the `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, and `DB_PORT` variables, the connection uses `sslmode=require`.
- The database timezone is set to `Asia/Jakarta`.

## Running Locally

```bash
cd backend
go mod download
go run main.go
```

Health check:

```text
http://localhost:8080/health
```

If `APP_PORT` is not set, the server runs on port `7860` by default.

## Build Binary

Windows:

```bash
cd backend
go build -o ecoconnect.exe .
```

Linux/macOS:

```bash
cd backend
go build -o ecoconnect .
```

## API Endpoints

Base path:

```text
/api
```

### Public

| Method | Endpoint | Handler | Description |
| --- | --- | --- | --- |
| `POST` | `/api/auth/daftar` | `Register` | User registration |
| `POST` | `/api/auth/masuk` | `Login` | Login and retrieve a JWT |
| `GET` | `/health` | inline | Health check |

### Protected

All endpoints below require this header:

```text
Authorization: Bearer <token>
```

| Method | Endpoint | Handler | Description |
| --- | --- | --- | --- |
| `GET` | `/api/actions` | `GetActions` | List eco-friendly actions |
| `POST` | `/api/checkin` | `CheckIn` | Submit a user action |
| `GET` | `/api/profil/:id` | `GetProfile` | Profile details |
| `PUT` | `/api/profil` | `UpdateProfile` | Update the logged-in user's profile |
| `GET` | `/api/papan-peringkat` | `GetLeaderboard` | User rankings |
| `GET` | `/api/riwayat` | `GetRiwayat` | User activity history |
| `GET` | `/api/communities` | `GetCommunities` | Community list |
| `POST` | `/api/communities/:id/join` | `ToggleJoinCommunity` | Join/leave a community |
| `GET` | `/api/communities/:id/messages` | `GetCommunityMessages` | Fetch forum messages |
| `POST` | `/api/communities/:id/messages` | `SendCommunityMessage` | Send a forum message |

### Legacy Compatibility

Older endpoints are still registered for compatibility:

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/api/tugas` | List legacy tasks |
| `POST` | `/api/tugas/:id/selesai` | Complete a legacy task |
| `GET` | `/api/grup` | List legacy groups |
| `POST` | `/api/grup/:id/bergabung` | Join a legacy group |
| `GET` | `/api/grup/:id/pesan` | Fetch legacy group messages |
| `POST` | `/api/grup/:id/pesan` | Send a legacy group message |

## Example Requests

Login:

```bash
curl -X POST http://localhost:8080/api/auth/masuk \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"user@example.com\",\"password\":\"password123\"}"
```

Check-in:

```bash
curl -X POST http://localhost:8080/api/checkin \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"action_id\":4,\"input_value\":10,\"notes\":\"Morning bike ride\"}"
```

Fetch communities:

```bash
curl http://localhost:8080/api/communities \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Main Models

AutoMigrate covers these models:

- `User`
- `Task`
- `UserTask`
- `Badge`
- `Group`
- `GroupMember`
- `GroupMessage`
- `Action`
- `UserActionLog`
- `Community`
- `ChatMessage`
- `CommunityMember`

## Seed Data

When the tables are still empty, the backend creates initial data:

- Legacy tasks for Vegan Diet, Energy Saving, and Green Transportation categories.
- Actions for the five main categories.
- Communities for the five main categories.
- Premium mission points are adjusted to be higher for selected missions.

## CORS

CORS is currently open to all origins:

```text
AllowOrigins: *
AllowHeaders: Origin, Content-Type, Accept, Authorization
AllowMethods: GET, POST, PUT, DELETE, OPTIONS
```

For stricter production settings, limit `AllowOrigins` to the frontend domain in use.

## Deployment

The server reads `PORT`, so it works well on platforms that inject ports through environment variables, such as Hugging Face Spaces or other container platforms.

If using the root project Dockerfile, make sure the build context matches the location of `go.mod`. For backend-only deployment, the safest context is the `backend/` folder or a Dockerfile adjusted for this repository structure.

## Troubleshooting

Database connection fails:

- Make sure `.env` is located in the project root.
- Make sure `DATABASE_URL` is valid or all `DB_*` variables are complete.
- Make sure the Supabase pooler uses SSL.
- Make sure the IP/network allows the connection.

Frontend fails to login/register:

- Make sure the backend is running.
- Make sure the frontend uses the correct `API_BASE_URL`.
- For the Android emulator, use `http://10.0.2.2:PORT/api`.
- For a physical phone, use the computer's LAN IP instead of `localhost`.

Token is rejected:

- Make sure the `Authorization` header uses the `Bearer <token>` format.
- Make sure `JWT_SECRET` does not change between the login process and subsequent requests.
