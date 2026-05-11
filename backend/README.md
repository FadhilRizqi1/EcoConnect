# EcoConnect Backend

Backend EcoConnect adalah REST API berbasis Go untuk autentikasi, aksi ramah lingkungan, check-in, profil, leaderboard, komunitas, dan forum chat.

## Ringkasan

Backend memakai:

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

Saat aplikasi start, backend akan:

- Memuat `.env` dari root project (`../.env`).
- Connect ke PostgreSQL.
- Menjalankan GORM AutoMigrate.
- Seed data awal untuk task, action, dan community jika belum ada.
- Mengoreksi poin misi premium.
- Menjalankan server Fiber.

## Struktur Folder

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

Buat `.env` di root project, satu level di atas folder `backend/`:

```env
DATABASE_URL=postgres://USER:PASSWORD@HOST:PORT/DB_NAME?sslmode=require

# Alternatif jika tidak memakai DATABASE_URL:
DB_HOST=your-db-host
DB_PORT=6543
DB_USER=your-db-user
DB_PASSWORD=your-db-password
DB_NAME=postgres

JWT_SECRET=change_this_with_a_long_random_secret
APP_PORT=8080
```

Urutan port:

1. `PORT`
2. `APP_PORT`
3. `7860`

Catatan:

- `DATABASE_URL` diprioritaskan jika tersedia.
- Jika memakai variable `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, dan `DB_PORT`, koneksi memakai `sslmode=require`.
- Timezone database diset ke `Asia/Jakarta`.

## Menjalankan Lokal

```bash
cd backend
go mod download
go run main.go
```

Health check:

```text
http://localhost:8080/health
```

Jika `APP_PORT` tidak diset, server default berjalan di port `7860`.

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

## Endpoint API

Base path:

```text
/api
```

### Public

| Method | Endpoint | Handler | Keterangan |
| --- | --- | --- | --- |
| `POST` | `/api/auth/daftar` | `Register` | Registrasi user |
| `POST` | `/api/auth/masuk` | `Login` | Login dan ambil JWT |
| `GET` | `/health` | inline | Health check |

### Protected

Semua endpoint berikut butuh header:

```text
Authorization: Bearer <token>
```

| Method | Endpoint | Handler | Keterangan |
| --- | --- | --- | --- |
| `GET` | `/api/actions` | `GetActions` | Daftar aksi ramah lingkungan |
| `POST` | `/api/checkin` | `CheckIn` | Submit aksi user |
| `GET` | `/api/profil/:id` | `GetProfile` | Detail profil |
| `PUT` | `/api/profil` | `UpdateProfile` | Update profil user login |
| `GET` | `/api/papan-peringkat` | `GetLeaderboard` | Ranking user |
| `GET` | `/api/riwayat` | `GetRiwayat` | Riwayat aktivitas user |
| `GET` | `/api/communities` | `GetCommunities` | Daftar komunitas |
| `POST` | `/api/communities/:id/join` | `ToggleJoinCommunity` | Join/leave komunitas |
| `GET` | `/api/communities/:id/messages` | `GetCommunityMessages` | Ambil pesan forum |
| `POST` | `/api/communities/:id/messages` | `SendCommunityMessage` | Kirim pesan forum |

### Legacy Compatibility

Endpoint lama masih diregistrasikan untuk kompatibilitas:

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| `GET` | `/api/tugas` | Daftar task lama |
| `POST` | `/api/tugas/:id/selesai` | Selesaikan task lama |
| `GET` | `/api/grup` | Daftar grup lama |
| `POST` | `/api/grup/:id/bergabung` | Join grup lama |
| `GET` | `/api/grup/:id/pesan` | Ambil pesan grup lama |
| `POST` | `/api/grup/:id/pesan` | Kirim pesan grup lama |

## Contoh Request

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
  -d "{\"action_id\":4,\"input_value\":10,\"notes\":\"Bersepeda pagi\"}"
```

Ambil komunitas:

```bash
curl http://localhost:8080/api/communities \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Model Utama

AutoMigrate mencakup model:

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

Saat tabel masih kosong, backend membuat data awal:

- Task legacy untuk kategori Diet Vegan, Hemat Energi, dan Transportasi Hijau.
- Action untuk lima kategori utama.
- Community untuk lima kategori utama.
- Poin premium untuk beberapa misi disesuaikan agar lebih tinggi.

## CORS

CORS saat ini terbuka untuk semua origin:

```text
AllowOrigins: *
AllowHeaders: Origin, Content-Type, Accept, Authorization
AllowMethods: GET, POST, PUT, DELETE, OPTIONS
```

Untuk production yang lebih ketat, batasi `AllowOrigins` ke domain frontend yang dipakai.

## Deployment

Server membaca `PORT`, sehingga cocok untuk platform yang menyuntikkan port lewat environment variable seperti Hugging Face Spaces atau platform container lain.

Jika memakai Dockerfile root project, pastikan build context sesuai dengan lokasi `go.mod`. Untuk deployment backend saja, context yang paling aman adalah folder `backend/` atau Dockerfile yang sudah disesuaikan untuk struktur repository ini.

## Troubleshooting

Database gagal connect:

- Pastikan `.env` berada di root project.
- Pastikan `DATABASE_URL` valid atau semua variable `DB_*` lengkap.
- Pastikan Supabase pooler memakai SSL.
- Pastikan IP/network mengizinkan koneksi.

Frontend gagal login/register:

- Pastikan backend hidup.
- Pastikan frontend memakai `API_BASE_URL` yang benar.
- Untuk Android emulator gunakan `http://10.0.2.2:PORT/api`.
- Untuk HP fisik gunakan IP LAN komputer, bukan `localhost`.

Token ditolak:

- Pastikan header `Authorization` memakai format `Bearer <token>`.
- Pastikan `JWT_SECRET` tidak berubah antara proses login dan request berikutnya.
