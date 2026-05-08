package handlers

import (
	"ecoconnect/config"
	"ecoconnect/models"

	"github.com/gofiber/fiber/v2"
)

// GetActions mengembalikan semua aksi ramah lingkungan dari DB
// GET /api/actions
func GetActions(c *fiber.Ctx) error {
	var actions []models.Action
	query := config.DB.Order("is_premium DESC, points DESC")

	// Filter by category (Hick's Law: navigasi per kategori)
	if cat := c.Query("kategori"); cat != "" {
		query = query.Where("category = ?", cat)
	}

	if err := query.Find(&actions).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Gagal mengambil data aksi"})
	}

	return c.JSON(fiber.Map{
		"aksi":  actions,
		"total": len(actions),
	})
}

// CheckIn memproses check-in aksi oleh user
// POST /api/checkin
func CheckIn(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)

	type CheckInInput struct {
		ActionID   uint    `json:"action_id"`
		InputValue float64 `json:"input_value"`  // km, jam, jumlah, dll
		Notes      string  `json:"notes"`
	}

	var input CheckInInput
	if err := c.BodyParser(&input); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Format input tidak valid"})
	}

	if input.ActionID == 0 {
		return c.Status(400).JSON(fiber.Map{"error": "action_id wajib diisi"})
	}
	if input.InputValue <= 0 {
		input.InputValue = 1 // Default 1 kali / unit (Postel's Law)
	}

	// Ambil data aksi dari DB
	var action models.Action
	if err := config.DB.First(&action, input.ActionID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "Aksi tidak ditemukan"})
	}

	// Tesler's Law: Hitung poin & karbon di server
	pointsEarned := int(float64(action.Points) * input.InputValue)
	carbonSaved := action.CarbonValue * input.InputValue

	// Catat check-in
	log := models.UserActionLog{
		UserID:       userID,
		ActionID:     input.ActionID,
		InputValue:   input.InputValue,
		Notes:        input.Notes,
		PointsEarned: pointsEarned,
		CarbonSaved:  carbonSaved,
	}
	if err := config.DB.Create(&log).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Gagal menyimpan check-in"})
	}

	// Update poin & karbon user
	config.DB.Model(&models.User{}).Where("id = ?", userID).
		Updates(map[string]interface{}{
			"reputation_points": config.DB.Raw("reputation_points + ?", pointsEarned),
		})

	config.DB.Exec(
		"UPDATE users SET reputation_points = reputation_points + ?, total_carbon_saved = total_carbon_saved + ? WHERE id = ?",
		pointsEarned, carbonSaved, userID,
	)

	// Update level user
	updateUserLevel(userID)

	// Cek badge pertama
	var logCount int64
	config.DB.Model(&models.UserActionLog{}).Where("user_id = ?", userID).Count(&logCount)
	if logCount == 1 {
		badge := models.Badge{
			UserID:      userID,
			Name:        "Langkah Pertama",
			Description: "Berhasil melakukan check-in pertama!",
			IconURL:     "🌱",
		}
		config.DB.Create(&badge)
	}

	return c.Status(201).JSON(fiber.Map{
		"pesan":        "Check-in berhasil! 🌿",
		"poin_didapat": pointsEarned,
		"karbon_hemat": carbonSaved,
		"konfeti":      true,
	})
}

// updateUserLevel is defined in task.go
