package models

import (
	"time"

	"gorm.io/gorm"
)

// User represents an EcoConnect member
type User struct {
	gorm.Model
	ID             uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Name           string         `gorm:"not null;size:100" json:"name"`
	Email          string         `gorm:"uniqueIndex;not null;size:255" json:"email"`
	Password       string         `gorm:"not null" json:"-"`
	Avatar         string         `gorm:"size:500" json:"avatar"`
	Bio            string         `gorm:"size:500" json:"bio"`

	// Social Capital (Hukum Tesler – kompleksitas disimpan di backend)
	ReputationPoints int     `gorm:"default:0" json:"reputation_points"`
	TotalCarbonSaved float64 `gorm:"default:0" json:"total_carbon_saved"`
	Level            string  `gorm:"default:'Tunas';size:50" json:"level"` // 8-Rank System

	// Onboarding categories (Hukum Hick – max 5 pilihan)
	Category         string       `gorm:"size:100" json:"category"` // e.g. "Diet Vegan", "Hemat Energi"

	// Relations
	Badges           []Badge      `gorm:"foreignKey:UserID" json:"badges,omitempty"`
	Tasks            []UserTask   `gorm:"foreignKey:UserID" json:"tasks,omitempty"`
	Groups           []GroupMember `gorm:"foreignKey:UserID" json:"groups,omitempty"`

	CreatedAt        time.Time    `json:"created_at"`
	UpdatedAt        time.Time    `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `gorm:"index" json:"-"`
}
