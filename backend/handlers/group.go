package handlers

import (
	"ecoconnect/config"
	"ecoconnect/models"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// GetGroups – Ambil daftar grup berdasarkan kategori (Group Polarization Law)
// GET /api/grup?kategori=Diet Vegan
func GetGroups(c *fiber.Ctx) error {
	category := c.Query("kategori")

	var groups []models.Group
	query := config.DB.Model(&models.Group{})
	if category != "" {
		query = query.Where("category = ?", category)
	}

	if err := query.Find(&groups).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Gagal memuat daftar grup",
		})
	}

	return c.JSON(fiber.Map{"grup": groups})
}

// JoinGroup – Bergabung dengan grup komunitas
// POST /api/grup/:id/bergabung
func JoinGroup(c *fiber.Ctx) error {
	groupID, _ := strconv.Atoi(c.Params("id"))
	userID := c.Locals("user_id").(uint)

	member := models.GroupMember{
		GroupID: uint(groupID),
		UserID:  userID,
		Role:    "member",
	}

	if err := config.DB.Where(models.GroupMember{GroupID: uint(groupID), UserID: userID}).
		FirstOrCreate(&member).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Gagal bergabung dengan grup",
		})
	}

	// Update member count
	var count int64
	config.DB.Model(&models.GroupMember{}).Where("group_id = ?", groupID).Count(&count)
	config.DB.Model(&models.Group{}).Where("id = ?", groupID).Update("member_count", count)

	return c.JSON(fiber.Map{
		"pesan": "Berhasil bergabung dengan komunitas! 🌿",
	})
}

// GetGroupMessages – Ambil pesan forum grup
// GET /api/grup/:id/pesan
func GetGroupMessages(c *fiber.Ctx) error {
	groupID, _ := strconv.Atoi(c.Params("id"))

	var messages []models.GroupMessage
	config.DB.
		Preload("User", func(db *gorm.DB) *gorm.DB {
			return db.Select("id, name, avatar, level")
		}).
		Where("group_id = ?", groupID).
		Order("created_at DESC").
		Limit(50).
		Find(&messages)

	return c.JSON(fiber.Map{"pesan": messages})
}

// SendGroupMessage – Kirim pesan ke forum grup
// POST /api/grup/:id/pesan
func SendGroupMessage(c *fiber.Ctx) error {
	groupID, _ := strconv.Atoi(c.Params("id"))
	userID := c.Locals("user_id").(uint)

	type Input struct {
		Isi string `json:"isi"`
	}
	input := new(Input)
	if err := c.BodyParser(input); err != nil || input.Isi == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Pesan tidak boleh kosong",
		})
	}

	msg := models.GroupMessage{
		GroupID: uint(groupID),
		UserID:  userID,
		Content: input.Isi,
	}
	config.DB.Create(&msg)

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"pesan":   "Pesan terkirim!",
		"data":    msg,
	})
}
