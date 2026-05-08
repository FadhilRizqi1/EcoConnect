package models

import (
	"time"

	"gorm.io/gorm"
)

// TaskCategory maps to Hick's Law onboarding categories (max 5)
type TaskCategory string

const (
	CategoryVegan      TaskCategory = "Diet Vegan"
	CategoryEnergy     TaskCategory = "Hemat Energi"
	CategoryTransport  TaskCategory = "Transportasi Hijau"
	CategoryWaste      TaskCategory = "Kelola Sampah"
	CategoryWater      TaskCategory = "Hemat Air"
)

// Task represents an eco-action available in the app
// Miller's Law: grouped into max 7±2 items per category
type Task struct {
	gorm.Model
	ID              uint         `gorm:"primaryKey;autoIncrement" json:"id"`
	Title           string       `gorm:"not null;size:200" json:"title"`           // e.g. "Makan Vegan Hari Ini"
	Description     string       `gorm:"size:1000" json:"description"`
	Category        TaskCategory `gorm:"not null;size:100;index" json:"category"`
	ImpactPoints    int          `gorm:"default:10" json:"impact_points"`          // Reward points
	CarbonSavedKg   float64      `gorm:"default:0" json:"carbon_saved_kg"`         // Tesler's Law: computed server-side
	IsPremium       bool         `gorm:"default:false" json:"is_premium"`          // Von Restorff: amber card
	IconURL         string       `gorm:"size:500" json:"icon_url"`
	FriendsCompleted int         `gorm:"-" json:"friends_completed"`               // Social Influence: injected at runtime

	// Relations
	UserTasks []UserTask `gorm:"foreignKey:TaskID" json:"-"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// UserTask tracks a user's completion of a task
type UserTask struct {
	gorm.Model
	ID          uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID      uint           `gorm:"not null;index" json:"user_id"`
	TaskID      uint           `gorm:"not null;index" json:"task_id"`
	CompletedAt *time.Time     `json:"completed_at"`
	IsCompleted bool           `gorm:"default:false" json:"is_completed"`
	Notes       string         `gorm:"size:500" json:"notes"` // Postel's Law: flexible user input
	CarbonLog   float64        `gorm:"default:0" json:"carbon_log"`

	// Relations
	User User `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Task Task `gorm:"foreignKey:TaskID" json:"task,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
