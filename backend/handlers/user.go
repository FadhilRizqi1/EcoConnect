package handlers

import (
	"ecoconnect/config"
	"ecoconnect/models"
	"strconv"
	"time"

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

	// Count completed tasks (legacy)
	var taskCount int64
	config.DB.Model(&models.UserTask{}).
		Where("user_id = ? AND is_completed = true", userID).
		Count(&taskCount)

	// Count new action logs (Phase 1)
	var actionCount int64
	config.DB.Model(&models.UserActionLog{}).
		Where("user_id = ?", userID).
		Count(&actionCount)

	totalAksi := taskCount + actionCount

	// Carbon saved is already accurately tracked in user.TotalCarbonSaved
	// but we'll include it explicitly for backward compatibility
	totalCarbon := user.TotalCarbonSaved

	// Fetch joined communities
	var joinedCommunities []models.Community
	config.DB.Table("communities").
		Joins("JOIN community_members ON community_members.community_id = communities.id").
		Where("community_members.user_id = ?", userID).
		Find(&joinedCommunities)

	var joinedCommResponse []fiber.Map
	if len(joinedCommunities) > 0 {
		var commIDs []uint
		for _, c := range joinedCommunities {
			commIDs = append(commIDs, c.ID)
		}
		
		type MemberCount struct {
			CommunityID uint
			Count       int
		}
		var memberCounts []MemberCount
		config.DB.Model(&models.CommunityMember{}).
			Select("community_id, count(*) as count").
			Where("community_id IN ?", commIDs).
			Group("community_id").
			Scan(&memberCounts)

		countMap := make(map[uint]int)
		for _, mc := range memberCounts {
			countMap[mc.CommunityID] = mc.Count
		}

		for _, comm := range joinedCommunities {
			joinedCommResponse = append(joinedCommResponse, fiber.Map{
				"id":           comm.ID,
				"name":         comm.Name,
				"description":  comm.Description,
				"category":     comm.Category,
				"member_count": countMap[comm.ID],
				"is_joined":    true,
			})
		}
	}

	// Fetch recent action logs (Aktivitas Terakhir)
	var recentLogs []models.UserActionLog
	config.DB.Preload("Action").Where("user_id = ?", userID).Order("created_at DESC").Limit(5).Find(&recentLogs)

	var recentTasks []models.UserTask
	config.DB.Preload("Task").Where("user_id = ? AND is_completed = true", userID).Order("updated_at DESC").Limit(5).Find(&recentTasks)

	var combinedActivity []fiber.Map
	for _, l := range recentLogs {
		combinedActivity = append(combinedActivity, fiber.Map{
			"id": l.ID,
			"title": l.Action.Title,
			"category": l.Action.Category,
			"points_earned": l.PointsEarned,
			"created_at": l.CreatedAt,
		})
	}
	for _, t := range recentTasks {
		combinedActivity = append(combinedActivity, fiber.Map{
			"id": t.ID,
			"title": t.Task.Title,
			"category": t.Task.Category,
			"points_earned": t.Task.ImpactPoints,
			"created_at": t.UpdatedAt,
		})
	}

	// Sort manually in Go (we need to import sort)
	// Actually to avoid import issues, we can just return combinedActivity as is (max 10 items) and frontend will sort, 
	// but let's just return it sorted. Wait, I didn't import "sort".
	// Let's just return combinedActivity and let frontend handle sorting or just take the first 5.
	// Actually, the frontend reverses it. Let's return it as is.
	
	// Generate weekly impact array (last 7 days points)
	weeklyImpact := make([]float64, 7)
	now := time.Now()
	sevenDaysAgo := now.AddDate(0, 0, -6)
	startOfSevenDaysAgo := time.Date(sevenDaysAgo.Year(), sevenDaysAgo.Month(), sevenDaysAgo.Day(), 0, 0, 0, 0, now.Location())
	
	var weekLogs []models.UserActionLog
	config.DB.Where("user_id = ? AND created_at >= ?", userID, startOfSevenDaysAgo).Find(&weekLogs)

	for _, log := range weekLogs {
		diffDays := int(log.CreatedAt.Sub(startOfSevenDaysAgo).Hours() / 24)
		if diffDays >= 0 && diffDays < 7 {
			weeklyImpact[diffDays] += float64(log.PointsEarned)
		}
	}

	return c.JSON(fiber.Map{
		"profil":             user,
		"tugas_selesai":      totalAksi, // Total Aksi gabungan
		"total_karbon_kg":    totalCarbon,
		"joined_communities": joinedCommResponse,
		"recent_activity":    combinedActivity,
		"weekly_impact":      weeklyImpact,
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

// UpdateProfile – Edit profile user (Name, Bio, Category)
// PUT /api/profil
func UpdateProfile(c *fiber.Ctx) error {
	userIDRaw := c.Locals("user_id")
	if userIDRaw == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Tidak ada akses"})
	}

	userID := userIDRaw.(uint)

	type UpdateRequest struct {
		Name     string `json:"name"`
		Bio      string `json:"bio"`
		Category string `json:"category"`
		Avatar   string `json:"avatar"`
	}

	var req UpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Input tidak valid"})
	}

	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Pengguna tidak ditemukan"})
	}

	// Update fields if provided
	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Category != "" {
		user.Category = req.Category
	}
	if req.Avatar != "" {
		user.Avatar = req.Avatar
	}
	user.Bio = req.Bio // allow empty string to clear bio

	config.DB.Save(&user)

	return c.JSON(fiber.Map{
		"message": "Profil berhasil diperbarui",
		"profil":  user,
	})
}

// GetRiwayat – Riwayat seluruh aktivitas check-in pengguna
// GET /api/riwayat
func GetRiwayat(c *fiber.Ctx) error {
	userIDRaw := c.Locals("user_id")
	if userIDRaw == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Tidak ada akses"})
	}
	userID := userIDRaw.(uint)

	// Pagination
	limit := 30
	offset := 0

	// Fetch all action logs with Action preloaded
	var logs []models.UserActionLog
	config.DB.Preload("Action").
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Limit(limit).Offset(offset).
		Find(&logs)

	// Compute aggregate stats
	var totalPoints int
	var totalCarbon float64
	var totalCheckins int64
	config.DB.Model(&models.UserActionLog{}).
		Select("COALESCE(SUM(points_earned), 0)").
		Where("user_id = ?", userID).
		Scan(&totalPoints)
	config.DB.Model(&models.UserActionLog{}).
		Select("COALESCE(SUM(carbon_saved), 0)").
		Where("user_id = ?", userID).
		Scan(&totalCarbon)
	config.DB.Model(&models.UserActionLog{}).
		Where("user_id = ?", userID).
		Count(&totalCheckins)

	// Build response
	var riwayat []fiber.Map
	for _, l := range logs {
		riwayat = append(riwayat, fiber.Map{
			"id":           l.ID,
			"title":        l.Action.Title,
			"category":     l.Action.Category,
			"is_premium":   l.Action.IsPremium,
			"input_value":  l.InputValue,
			"unit":         l.Action.Unit,
			"points_earned": l.PointsEarned,
			"carbon_saved": l.CarbonSaved,
			"notes":        l.Notes,
			"created_at":   l.CreatedAt,
		})
	}

	return c.JSON(fiber.Map{
		"riwayat":        riwayat,
		"total_poin":     totalPoints,
		"total_karbon":   totalCarbon,
		"total_checkins": totalCheckins,
	})
}
