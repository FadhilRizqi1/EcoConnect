package models

import (
	"time"

	"gorm.io/gorm"
)

// Badge represents Social Capital (Hukum Social Capital)
type Badge struct {
	gorm.Model
	ID          uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID      uint           `gorm:"not null;index" json:"user_id"`
	Name        string         `gorm:"not null;size:100" json:"name"`        // e.g. "Pejuang Vegan"
	Description string         `gorm:"size:300" json:"description"`
	IconURL     string         `gorm:"size:500" json:"icon_url"`
	EarnedAt    time.Time      `json:"earned_at"`

	User        User           `gorm:"foreignKey:UserID" json:"user,omitempty"`

	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

// Group represents a niche eco-community (Group Polarization Law)
type Group struct {
	gorm.Model
	ID          uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Name        string         `gorm:"not null;size:100" json:"name"`         // e.g. "Komunitas Diet Vegan Jakarta"
	Description string         `gorm:"size:500" json:"description"`
	Category    TaskCategory   `gorm:"not null;size:100;index" json:"category"`
	AvatarURL   string         `gorm:"size:500" json:"avatar_url"`
	MemberCount int            `gorm:"default:0" json:"member_count"`

	Members     []GroupMember  `gorm:"foreignKey:GroupID" json:"members,omitempty"`
	Messages    []GroupMessage `gorm:"foreignKey:GroupID" json:"messages,omitempty"`

	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

// GroupMember join table for users in groups
type GroupMember struct {
	gorm.Model
	ID      uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	GroupID uint           `gorm:"not null;index" json:"group_id"`
	UserID  uint           `gorm:"not null;index" json:"user_id"`
	Role    string         `gorm:"default:'member';size:20" json:"role"` // member, admin

	Group   Group          `gorm:"foreignKey:GroupID" json:"group,omitempty"`
	User    User           `gorm:"foreignKey:UserID" json:"user,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// GroupMessage for the Discussion Forum (Group Polarization Law)
type GroupMessage struct {
	gorm.Model
	ID        uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	GroupID   uint           `gorm:"not null;index" json:"group_id"`
	UserID    uint           `gorm:"not null;index" json:"user_id"`
	Content   string         `gorm:"not null;size:2000" json:"content"`

	Group     Group          `gorm:"foreignKey:GroupID" json:"group,omitempty"`
	User      User           `gorm:"foreignKey:UserID" json:"user,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
