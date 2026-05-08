package handlers

import (
	"ecoconnect/config"
	"ecoconnect/models"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// GetCommunities mengembalikan semua komunitas
// GET /api/communities
func GetCommunities(c *fiber.Ctx) error {
	var communities []models.Community
	query := config.DB.Order("member_count DESC")

	if cat := c.Query("kategori"); cat != "" {
		query = query.Where("category = ?", cat)
	}

	if err := query.Find(&communities).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Gagal mengambil data komunitas"})
	}

	return c.JSON(fiber.Map{
		"komunitas": communities,
		"total":     len(communities),
	})
}

// GetCommunityMessages mengambil pesan dari komunitas tertentu
// GET /api/communities/:id/messages
func GetCommunityMessages(c *fiber.Ctx) error {
	communityID := c.Params("id")

	var messages []models.ChatMessage
	err := config.DB.
		Preload("User", func(db *gorm.DB) *gorm.DB {
			return db.Select("id, name, level, avatar")
		}).
		Where("community_id = ?", communityID).
		Order("created_at ASC").
		Limit(100).
		Find(&messages).Error

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Gagal mengambil pesan"})
	}

	return c.JSON(fiber.Map{
		"pesan": messages,
		"total": len(messages),
	})
}

// SendCommunityMessage mengirim pesan ke komunitas
// POST /api/communities/:id/messages
func SendCommunityMessage(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)
	communityID, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "ID komunitas tidak valid"})
	}

	type MsgInput struct {
		Message string `json:"message"`
	}
	var input MsgInput
	if err := c.BodyParser(&input); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Format input tidak valid"})
	}
	if input.Message == "" {
		return c.Status(400).JSON(fiber.Map{"error": "Pesan tidak boleh kosong"})
	}

	// Ambil nama & level user
	var user models.User
	config.DB.Select("id, name, level").First(&user, userID)

	msg := models.ChatMessage{
		CommunityID: uint(communityID),
		UserID:      userID,
		SenderName:  user.Name,
		Message:     input.Message,
	}
	if err := config.DB.Create(&msg).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Gagal mengirim pesan"})
	}

	// Update jumlah anggota jika belum join
	config.DB.Exec(
		"UPDATE communities SET member_count = member_count + 1 WHERE id = ? AND id NOT IN (SELECT community_id FROM chat_messages WHERE user_id = ? AND community_id = ? AND id < ?)",
		communityID, userID, communityID, msg.ID,
	)

	// Attach user info untuk response
	msg.User = user

	return c.Status(201).JSON(fiber.Map{
		"pesan": "Pesan terkirim",
		"data":  msg,
	})
}
