package handlers

import (
	"ecoconnect/config"
	"ecoconnect/models"
	"ecoconnect/utils"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"os"
	"strings"
)

type RegisterInput struct {
	Name     string `json:"name" validate:"required"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
	Category string `json:"category"` // Hick's Law: onboarding category
}

type LoginInput struct {
	Email    string `json:"email" validate:"required"`
	Password string `json:"password" validate:"required"`
}

// Register – Daftar akun baru
// POST /api/auth/daftar
func Register(c *fiber.Ctx) error {
	input := new(RegisterInput)
	if err := c.BodyParser(input); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Format data tidak valid",
		})
	}

	// Validate category (Hick's Law – only allowed categories)
	if input.Category != "" {
		allowed := map[string]bool{
			"Diet Vegan": true, "Hemat Energi": true,
			"Transportasi Hijau": true, "Kelola Sampah": true, "Hemat Air": true,
		}
		if !allowed[input.Category] {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "Kategori tidak valid. Pilih salah satu: Diet Vegan, Hemat Energi, Transportasi Hijau, Kelola Sampah, Hemat Air",
			})
		}
	}

	// Hash password
	hashed, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Gagal memproses kata sandi",
		})
	}

	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hashed),
		Category: input.Category,
		Level:    "Pemula",
	}

	if result := config.DB.Create(&user); result.Error != nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{
			"error": "Email sudah terdaftar",
		})
	}

	// Auto-join community based on multiple categories
	if user.Category != "" {
		categories := strings.Split(user.Category, ",")
		tagMap := map[string]string{
			"Diet Vegan":         "Vegan",
			"Hemat Energi":       "Energi",
			"Transportasi Hijau": "Transportasi",
			"Kelola Sampah":      "Sampah",
			"Hemat Air":          "Air",
		}
		
		for _, cat := range categories {
			cat = strings.TrimSpace(cat)
			if cat == "" {
				continue
			}

			var community models.Community
			searchStr := "%" + cat + "%"
			if tag, ok := tagMap[cat]; ok {
				searchStr = "%" + tag + "%"
			}

			if err := config.DB.Where("name LIKE ? OR category LIKE ?", searchStr, searchStr).First(&community).Error; err == nil {
				// Prevent duplicate join if somehow repeated
				var count int64
				config.DB.Model(&models.CommunityMember{}).Where("community_id = ? AND user_id = ?", community.ID, user.ID).Count(&count)
				if count == 0 {
					config.DB.Create(&models.CommunityMember{
						CommunityID: community.ID,
						UserID:      user.ID,
					})
					config.DB.Model(&community).UpdateColumn("member_count", gorm.Expr("member_count + ?", 1))
				}
			}
		}
	}

	token, err := utils.GenerateJWT(user.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Gagal membuat token",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Selamat datang di EcoConnect, " + user.Name + "! 🌿",
		"token":   token,
		"user":    user,
	})
}

// Login – Masuk ke akun
// POST /api/auth/masuk
func Login(c *fiber.Ctx) error {
	input := new(LoginInput)
	if err := c.BodyParser(input); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Format data tidak valid",
		})
	}

	var user models.User
	if result := config.DB.Where("email = ?", input.Email).First(&user); result.Error != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Email atau kata sandi salah",
		})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Email atau kata sandi salah",
		})
	}

	token, err := utils.GenerateJWT(user.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Gagal membuat token",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Berhasil masuk! Selamat berjuang untuk bumi 🌍",
		"token":   token,
		"user":    user,
	})
}

// generateJWT helper (kept local for reference – actual impl in utils)
func generateJWT(userID uint) (string, error) {
	secret := os.Getenv("JWT_SECRET")
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(7 * 24 * time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}
