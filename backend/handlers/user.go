package handlers

import (
	"ecoconnect/config"
	"ecoconnect/models"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

// GetProfile – Lihat profil pengguna (Social Capital display)
// GET /api/profil/:id
func GetProfile(c *fiber.Ctx) error {
	userID, _ := strconv.Atoi(c.Params("id"))

	var user models.User
	result := config.DB.
		Preload("Badges").
		First(&user, userID)

	if result.Error != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Pengguna tidak ditemukan",
		})
	}

	// Count completed tasks
	var completedCount int64
	config.DB.Model(&models.UserTask{}).
		Where("user_id = ? AND is_completed = true", userID).
		Count(&completedCount)

	return c.JSON(fiber.Map{
		"profil":          user,
		"tugas_selesai":   completedCount,
		"total_karbon_kg": getTotalCarbon(uint(userID)),
	})
}

// GetLeaderboard – Papan peringkat (Social Capital)
// GET /api/papan-peringkat
func GetLeaderboard(c *fiber.Ctx) error {
	var users []models.User
	config.DB.Select("id, name, avatar, reputation_points, level, category").
		Order("reputation_points DESC").
		Limit(20).
		Find(&users)

	return c.JSON(fiber.Map{
		"peringkat": users,
	})
}

func getTotalCarbon(userID uint) float64 {
	var total float64
	config.DB.Model(&models.UserTask{}).
		Where("user_id = ? AND is_completed = true", userID).
		Select("COALESCE(SUM(carbon_log), 0)").
		Scan(&total)
	return total
}
