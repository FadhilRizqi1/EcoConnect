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
	userID := c.Locals("user_id").(uint)

	var communities []models.Community
	query := config.DB.Order("member_count DESC")

	if cat := c.Query("kategori"); cat != "" {
		query = query.Where("category = ?", cat)
	}

	if err := query.Find(&communities).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Gagal mengambil data komunitas"})
	}

	// Ambil daftar komunitas yang diikuti user
	var joinedIDs []uint
	config.DB.Model(&models.CommunityMember{}).Where("user_id = ?", userID).Pluck("community_id", &joinedIDs)

	joinedMap := make(map[uint]bool)
	for _, id := range joinedIDs {
		joinedMap[id] = true
	}

	// Hitung jumlah member riil dari database (Authentic Count)
	type MemberCount struct {
		CommunityID uint
		Count       int
	}
	var memberCounts []MemberCount
	config.DB.Model(&models.CommunityMember{}).
		Select("community_id, count(*) as count").
		Group("community_id").
		Scan(&memberCounts)

	countMap := make(map[uint]int)
	for _, mc := range memberCounts {
		countMap[mc.CommunityID] = mc.Count
	}

	var response []fiber.Map
	for _, comm := range communities {
		response = append(response, fiber.Map{
			"id":           comm.ID,
			"name":         comm.Name,
			"description":  comm.Description,
			"category":     comm.Category,
			"member_count": countMap[comm.ID], // Authentic member count!
			"is_joined":    joinedMap[comm.ID],
		})
	}

	return c.JSON(fiber.Map{
		"komunitas": response,
		"total":     len(communities),
	})
}

// ToggleJoinCommunity bergabung atau keluar dari komunitas
// POST /api/communities/:id/join
func ToggleJoinCommunity(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)
	communityID, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "ID komunitas tidak valid"})
	}

	var member models.CommunityMember
	result := config.DB.Where("user_id = ? AND community_id = ?", userID, communityID).First(&member)

	if result.Error == nil {
		// Sudah join, maka keluar (leave)
		config.DB.Delete(&member)
		config.DB.Exec("UPDATE communities SET member_count = member_count - 1 WHERE id = ?", communityID)
		return c.JSON(fiber.Map{"pesan": "Berhasil keluar dari komunitas", "is_joined": false})
	} else {
		// Belum join, maka gabung
		newMember := models.CommunityMember{
			UserID:      userID,
			CommunityID: uint(communityID),
		}
		config.DB.Create(&newMember)
		config.DB.Exec("UPDATE communities SET member_count = member_count + 1 WHERE id = ?", communityID)
		return c.JSON(fiber.Map{"pesan": "Berhasil bergabung dengan komunitas", "is_joined": true})
	}
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

	// Ambil nama, level, & avatar user
	var user models.User
	config.DB.Select("id, name, level, avatar").First(&user, userID)

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
