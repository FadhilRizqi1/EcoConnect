package models

import (
	"time"

	"gorm.io/gorm"
)

// Action mewakili aksi ramah lingkungan yang tersedia di app
// Setara dengan Task tapi dengan nama lebih sesuai instruksi baru
type Action struct {
	gorm.Model
	ID          uint         `gorm:"primaryKey;autoIncrement" json:"id"`
	Title       string       `gorm:"not null;size:200" json:"title"`
	Description string       `gorm:"size:1000" json:"description"`
	Category    TaskCategory `gorm:"not null;size:100;index" json:"category"`
	Points      int          `gorm:"default:10" json:"points"`
	CarbonValue float64      `gorm:"default:0" json:"carbon_value"`     // kg CO2 per unit input
	IsPremium   bool         `gorm:"default:false" json:"is_premium"`  // Von Restorff: amber highlight
	Unit        string       `gorm:"size:50;default:'kali'" json:"unit"` // satuan input: "km", "kWh", "kali"

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// UserActionLog mencatat setiap check-in user (real data, bukan dummy)
// Tesler's Law: perhitungan poin & karbon dilakukan server-side
type UserActionLog struct {
	gorm.Model
	ID         uint    `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID     uint    `gorm:"not null;index" json:"user_id"`
	ActionID   uint    `gorm:"not null;index" json:"action_id"`
	InputValue float64 `gorm:"default:1" json:"input_value"` // e.g. 5 (km), 2 (jam), 1 (kali)
	Notes      string  `gorm:"size:500" json:"notes"`        // Postel's Law: input bebas
	PointsEarned int   `gorm:"default:0" json:"points_earned"`
	CarbonSaved  float64 `gorm:"default:0" json:"carbon_saved"`

	// Relations
	User   User   `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Action Action `gorm:"foreignKey:ActionID" json:"action,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// Community mewakili komunitas niche (Group Polarization Law)
type Community struct {
	gorm.Model
	ID          uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	Name        string `gorm:"not null;size:100" json:"name"`
	Description string `gorm:"size:500" json:"description"`
	Category    string `gorm:"size:100;index" json:"category"`
	MemberCount int    `gorm:"default:0" json:"member_count"`

	// Relations
	Messages []ChatMessage `gorm:"foreignKey:CommunityID" json:"messages,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// ChatMessage untuk pesan komunitas real (bukan dummy)
type ChatMessage struct {
	gorm.Model
	ID          uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	CommunityID uint   `gorm:"not null;index" json:"community_id"`
	UserID      uint   `gorm:"not null;index" json:"user_id"`
	SenderName  string `gorm:"size:100" json:"sender_name"` // disimpan untuk performa
	Message     string `gorm:"not null;size:2000" json:"message"`

	// Relations
	User      User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Community Community `gorm:"foreignKey:CommunityID" json:"community,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// CommunityMember melacak siapa saja yang bergabung dengan komunitas (authentic member count)
type CommunityMember struct {
	gorm.Model
	ID          uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	CommunityID uint   `gorm:"not null;index" json:"community_id"`
	UserID      uint   `gorm:"not null;index" json:"user_id"`

	// Relations
	User      User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Community Community `gorm:"foreignKey:CommunityID" json:"community,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
