package utils

import (
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// GenerateJWT creates a signed token for a user
func GenerateJWT(userID uint) (string, error) {
	secret := os.Getenv("JWT_SECRET")
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(7 * 24 * time.Hour).Unix(),
		"iat":     time.Now().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}

// ParseFlexibleNumber implements Postel's Law: accepts "10 km", "10.5", "10"
// and returns the numeric value.
func ParseFlexibleNumber(input string) float64 {
	// Strip non-numeric characters except dot
	var numStr string
	for _, ch := range input {
		if (ch >= '0' && ch <= '9') || ch == '.' {
			numStr += string(ch)
		}
	}
	if numStr == "" {
		return 0
	}
	var val float64
	_, err := fmt.Sscanf(numStr, "%f", &val)
	if err != nil {
		return 0
	}
	return val
}

// CalculateCarbonSaved implements Tesler's Law: complex carbon math lives here
// so the UI only needs to show a simple number.
// category: e.g. "Diet Vegan", distanceKm used for transport tasks
func CalculateCarbonSaved(category string, quantity float64) float64 {
	// CO2 emission factors (kg CO2 per unit)
	factors := map[string]float64{
		"Diet Vegan":         2.5,  // kg CO2 per meal replaced
		"Hemat Energi":       0.4,  // kg CO2 per kWh saved
		"Transportasi Hijau": 0.21, // kg CO2 per km not driven
		"Kelola Sampah":      0.5,  // kg CO2 per kg waste recycled
		"Hemat Air":          0.001,// kg CO2 per litre saved
	}
	factor, ok := factors[category]
	if !ok {
		return 0
	}
	return factor * quantity
}
