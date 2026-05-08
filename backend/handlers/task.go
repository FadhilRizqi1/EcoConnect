package handlers

import (
	"ecoconnect/config"
	"ecoconnect/models"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
)

// GetTasks – Ambil daftar tugas berdasarkan kategori
// GET /api/tugas?kategori=Diet Vegan
func GetTasks(c *fiber.Ctx) error {
	category := c.Query("kategori")
	userID := c.Locals("user_id").(uint)

	var tasks []models.Task
	query := config.DB.Model(&models.Task{})
	if category != "" {
		query = query.Where("category = ?", category)
	}
	// Miller's Law: limit 9 tasks per page
	query = query.Limit(9)

	if err := query.Find(&tasks).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Gagal memuat daftar tugas",
		})
	}

	// Social Influence: inject friends_completed count per task
	for i := range tasks {
		var count int64
		config.DB.Model(&models.UserTask{}).
			Where("task_id = ? AND is_completed = true", tasks[i].ID).
			Count(&count)
		tasks[i].FriendsCompleted = int(count)
	}

	_ = userID
	return c.JSON(fiber.Map{
		"tugas": tasks,
		"total": len(tasks),
	})
}

// CompleteTask – Tandai tugas selesai (Peak-End Rule: triggers celebration)
// POST /api/tugas/:id/selesai
func CompleteTask(c *fiber.Ctx) error {
	taskID, _ := strconv.Atoi(c.Params("id"))
	userID := c.Locals("user_id").(uint)

	// Postel's Law: accept flexible note input
	type Input struct {
		Catatan string `json:"catatan"`
	}
	input := new(Input)
	_ = c.BodyParser(input)

	// Get task for carbon calculation (Tesler's Law: done server-side)
	var task models.Task
	if err := config.DB.First(&task, taskID).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Tugas tidak ditemukan",
		})
	}

	now := time.Now()
	userTask := models.UserTask{
		UserID:      userID,
		TaskID:      uint(taskID),
		IsCompleted: true,
		CompletedAt: &now,
		Notes:       input.Catatan,
		CarbonLog:   task.CarbonSavedKg, // server-side carbon value
	}

	// Upsert: if already exists, update completion
	config.DB.Where(models.UserTask{UserID: userID, TaskID: uint(taskID)}).
		Assign(userTask).
		FirstOrCreate(&userTask)

	// Add reputation points (Social Capital)
	config.DB.Model(&models.User{}).Where("id = ?", userID).
		UpdateColumn("reputation_points", config.DB.Raw("reputation_points + ?", task.ImpactPoints))

	// Update user level based on points
	updateUserLevel(userID)

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"pesan":         "Luar biasa! Kamu baru saja menyelamatkan bumi 🎉",
		"konfeti":       true, // Frontend akan trigger animasi konfeti (Peak-End Rule)
		"poin_didapat":  task.ImpactPoints,
		"karbon_hemat":  task.CarbonSavedKg,
		"tugas":         userTask,
	})
}

// updateUserLevel computes level from reputation points
func updateUserLevel(userID uint) {
	var user models.User
	config.DB.Select("reputation_points").First(&user, userID)

	level := "Pemula"
	switch {
	case user.ReputationPoints >= 500:
		level = "Pahlawan Bumi"
	case user.ReputationPoints >= 150:
		level = "Penjaga Alam"
	}
	config.DB.Model(&models.User{}).Where("id = ?", userID).Update("level", level)
}
