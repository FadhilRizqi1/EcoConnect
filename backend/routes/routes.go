package routes

import (
	"ecoconnect/handlers"
	"ecoconnect/middleware"

	"github.com/gofiber/fiber/v2"
)

// Setup registers all API routes
func Setup(app *fiber.App) {
	api := app.Group("/api")

	// ── Auth (Publik) ──────────────────────────────────────────────
	auth := api.Group("/auth")
	auth.Post("/daftar", handlers.Register)  // Daftar akun baru
	auth.Post("/masuk", handlers.Login)      // Login

	// ── Protected routes (butuh JWT) ──────────────────────────────
	protected := api.Use(middleware.AuthRequired)

	// ── Aksi & Check-in ───────────────────────────────────────────
	protected.Get("/actions", handlers.GetActions)     // Daftar aksi eco
	protected.Post("/checkin", handlers.CheckIn)       // Submit check-in real

	// ── Tugas lama (kompatibilitas) ────────────────────────────────
	protected.Get("/tugas", handlers.GetTasks)
	protected.Post("/tugas/:id/selesai", handlers.CompleteTask)

	// ── Profil & Papan Peringkat (Social Capital) ─────────────────
	protected.Get("/profil/:id", handlers.GetProfile)
	protected.Put("/profil", handlers.UpdateProfile)
	protected.Get("/papan-peringkat", handlers.GetLeaderboard)
	protected.Get("/riwayat", handlers.GetRiwayat)

	// ── Komunitas (Community) ─────────────────────────────────────
	protected.Get("/communities", handlers.GetCommunities)
	protected.Post("/communities/:id/join", handlers.ToggleJoinCommunity)
	protected.Get("/communities/:id/messages", handlers.GetCommunityMessages)
	protected.Post("/communities/:id/messages", handlers.SendCommunityMessage)

	// ── Grup lama (kompatibilitas) ─────────────────────────────────
	protected.Get("/grup", handlers.GetGroups)
	protected.Post("/grup/:id/bergabung", handlers.JoinGroup)
	protected.Get("/grup/:id/pesan", handlers.GetGroupMessages)
	protected.Post("/grup/:id/pesan", handlers.SendGroupMessage)

	// Health check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "app": "EcoConnect API 🌿"})
	})
}
