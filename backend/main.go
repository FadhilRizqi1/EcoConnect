package main

import (
	"ecoconnect/config"
	"ecoconnect/models"
	"ecoconnect/routes"
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env file
	if err := godotenv.Load("../.env"); err != nil {
		log.Println("⚠️  .env tidak ditemukan, menggunakan environment variables sistem")
	}

	// Connect to database
	config.ConnectDB()

	// Auto-migrate all models
	if err := config.DB.AutoMigrate(
		&models.User{},
		&models.Task{},
		&models.UserTask{},
		&models.Badge{},
		&models.Group{},
		&models.GroupMember{},
		&models.GroupMessage{},
		// Phase 1: Model baru
		&models.Action{},
		&models.UserActionLog{},
		&models.Community{},
		&models.ChatMessage{},
		&models.CommunityMember{}, // Phase 3: Komunitas Member join table
	); err != nil {
		log.Fatalf("❌ AutoMigrate gagal: %v", err)
	}
	log.Println("✅ Database schema berhasil dimigrasikan")

	// Seed data awal
	seedDefaultTasks()
	seedDefaultActions()
	seedDefaultCommunities()
	updatePremiumPoints() // Pastikan poin premium selalu 3x poin biasa

	// Fiber app setup
	app := fiber.New(fiber.Config{
		AppName:      "EcoConnect API v1.0 🌿",
		ErrorHandler: customErrorHandler,
	})

	// Global middleware
	app.Use(recover.New())
	app.Use(logger.New(logger.Config{
		Format: "[${time}] ${status} ${method} ${path} - ${latency}\n",
	}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
		AllowMethods: "GET, POST, PUT, DELETE, OPTIONS",
	}))

	// Register routes
	routes.Setup(app)

	// Start server
	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("🚀 EcoConnect API berjalan di http://localhost:%s", port)
	log.Fatal(app.Listen(fmt.Sprintf(":%s", port)))
}

// customErrorHandler returns consistent Indonesian error messages
func customErrorHandler(c *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	if e, ok := err.(*fiber.Error); ok {
		code = e.Code
	}
	return c.Status(code).JSON(fiber.Map{
		"error": err.Error(),
	})
}

// seedDefaultTasks populates initial eco-tasks on first run
func seedDefaultTasks() {
	var count int64
	config.DB.Model(&models.Task{}).Count(&count)
	if count > 0 {
		return
	}

	tasks := []models.Task{
		// Diet Vegan (3 tasks)
		{Title: "Makan Vegan Hari Ini", Category: "Diet Vegan", ImpactPoints: 20, CarbonSavedKg: 2.5, Description: "Ganti satu makan dengan menu berbasis tanaman"},
		{Title: "Masak Makanan Nabati", Category: "Diet Vegan", ImpactPoints: 25, CarbonSavedKg: 2.8, Description: "Masak sendiri menu vegan di rumah"},
		{Title: "Kurangi Konsumsi Daging", Category: "Diet Vegan", ImpactPoints: 15, CarbonSavedKg: 1.5, Description: "Pilih alternatif protein nabati hari ini", IsPremium: true},
		// Hemat Energi (3 tasks)
		{Title: "Matikan Lampu Saat Pergi", Category: "Hemat Energi", ImpactPoints: 10, CarbonSavedKg: 0.2, Description: "Pastikan semua lampu mati saat meninggalkan ruangan"},
		{Title: "Kurangi AC 2 Jam", Category: "Hemat Energi", ImpactPoints: 15, CarbonSavedKg: 0.6, Description: "Gunakan kipas angin atau buka jendela sebagai alternatif"},
		{Title: "Cabut Charger Tidak Terpakai", Category: "Hemat Energi", ImpactPoints: 5, CarbonSavedKg: 0.1, Description: "Charger standby tetap mengonsumsi energi", IsPremium: true},
		// Transportasi Hijau (3 tasks)
		{Title: "Jalan Kaki ke Warung", Category: "Transportasi Hijau", ImpactPoints: 20, CarbonSavedKg: 0.5, Description: "Hindari naik motor untuk jarak < 1 km"},
		{Title: "Naik Transportasi Umum", Category: "Transportasi Hijau", ImpactPoints: 30, CarbonSavedKg: 1.2, Description: "Gunakan bus atau KRL hari ini"},
		{Title: "Bersepeda ke Kantor", Category: "Transportasi Hijau", ImpactPoints: 40, CarbonSavedKg: 2.1, Description: "Ganti perjalanan harian dengan bersepeda", IsPremium: true},
	}

	config.DB.Create(&tasks)
	log.Println("🌱 Data tugas awal berhasil ditambahkan")
}

// seedDefaultActions populates Action table (new model)
func seedDefaultActions() {
	var count int64
	config.DB.Model(&models.Action{}).Count(&count)
	if count > 0 {
		return
	}

	actions := []models.Action{
		// Diet Vegan
		{Title: "Makan Vegan Hari Ini", Category: "Diet Vegan", Points: 20, CarbonValue: 2.5, Unit: "kali", Description: "Ganti satu porsi makan dengan menu nabati"},
		{Title: "Masak Makanan Nabati", Category: "Diet Vegan", Points: 25, CarbonValue: 2.8, Unit: "kali", Description: "Masak sendiri menu vegan di rumah"},
		{Title: "Kurangi Konsumsi Daging", Category: "Diet Vegan", Points: 30, CarbonValue: 3.5, Unit: "kali", Description: "Pilih protein nabati sebagai pengganti daging", IsPremium: true},
		// Transportasi Hijau
		{Title: "Bersepeda ke Tujuan", Category: "Transportasi Hijau", Points: 10, CarbonValue: 0.21, Unit: "km", Description: "Masukkan jarak bersepeda dalam km", IsPremium: true},
		{Title: "Naik Transportasi Umum", Category: "Transportasi Hijau", Points: 15, CarbonValue: 0.08, Unit: "km", Description: "Masukkan jarak perjalanan dengan transportasi umum"},
		{Title: "Jalan Kaki", Category: "Transportasi Hijau", Points: 8, CarbonValue: 0.0, Unit: "km", Description: "Masukkan jarak berjalan kaki"},
		// Hemat Energi
		{Title: "Hemat Pemakaian AC", Category: "Hemat Energi", Points: 15, CarbonValue: 0.3, Unit: "jam", Description: "Masukkan berapa jam Anda tidak memakai AC"},
		{Title: "Matikan Perangkat Standby", Category: "Hemat Energi", Points: 10, CarbonValue: 0.05, Unit: "kali", Description: "Cabut charger dan perangkat tidak terpakai", IsPremium: true},
		// Kelola Sampah
		{Title: "Daur Ulang Sampah", Category: "Kelola Sampah", Points: 20, CarbonValue: 0.5, Unit: "kg", Description: "Masukkan berat sampah yang berhasil didaur ulang"},
		{Title: "Bawa Tas Belanja Sendiri", Category: "Kelola Sampah", Points: 10, CarbonValue: 0.1, Unit: "kali", Description: "Hindari kantong plastik sekali pakai"},
		// Hemat Air
		{Title: "Hemat Air Mandi", Category: "Hemat Air", Points: 10, CarbonValue: 0.02, Unit: "liter", Description: "Masukkan estimasi liter air yang dihemat"},
		{Title: "Tampung Air Hujan", Category: "Hemat Air", Points: 20, CarbonValue: 0.05, Unit: "liter", Description: "Gunakan air hujan untuk menyiram tanaman", IsPremium: true},
	}
	config.DB.Create(&actions)
	log.Println("⚡ Data aksi awal berhasil ditambahkan")
}

// updatePremiumPoints — pastikan misi premium selalu punya poin 3x lebih besar
// Dijalankan setiap startup untuk auto-koreksi data lama
func updatePremiumPoints() {
	// Set poin premium ke nilai yang lebih tinggi secara eksplisit
	updates := map[string]int{
		"Kurangi Konsumsi Daging":   90,
		"Bersepeda ke Tujuan":       30,
		"Matikan Perangkat Standby": 35,
		"Tampung Air Hujan":         60,
	}
	for title, pts := range updates {
		config.DB.Model(&models.Action{}).
			Where("title = ? AND is_premium = true", title).
			Update("points", pts)
	}
	log.Println("⭐ Poin misi premium diperbarui")
}

// seedDefaultCommunities populates Community table (new model)
func seedDefaultCommunities() {
	var count int64
	config.DB.Model(&models.Community{}).Count(&count)
	if count > 0 {
		return
	}

	communities := []models.Community{
		{Name: "Vegan Jakarta", Category: "Diet Vegan", Description: "Komunitas pecinta kuliner plant-based di Jakarta. Berbagi resep, restoran rekomendasi, dan tips hidup vegan!", MemberCount: 1240},
		{Name: "Pejuang Listrik Pintar", Category: "Hemat Energi", Description: "Diskusi tips menghemat tagihan listrik dan energi rumah tangga secara bijak.", MemberCount: 856},
		{Name: "Bike to Work ID", Category: "Transportasi Hijau", Description: "Komunitas pesepeda harian. Rute, tips keselamatan, dan motivasi bersepeda bersama!", MemberCount: 3420},
		{Name: "Bank Sampah Bersama", Category: "Kelola Sampah", Description: "Belajar daur ulang, manajemen sampah rumah, dan gaya hidup zero waste.", MemberCount: 2100},
		{Name: "Air Untuk Masa Depan", Category: "Hemat Air", Description: "Kampanye penghematan air bersih untuk generasi mendatang.", MemberCount: 510},
	}
	config.DB.Create(&communities)
	log.Println("🌍 Data komunitas (baru) berhasil ditambahkan")
}
