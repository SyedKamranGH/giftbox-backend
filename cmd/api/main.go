package main

import (
	"fmt"
	"log"

	"github.com/SyedKamranGH/giftbox-backend/internal/config"
	"github.com/SyedKamranGH/giftbox-backend/pkg/database"
	"github.com/SyedKamranGH/giftbox-backend/pkg/logger"
	"github.com/gin-gonic/gin"
)

// @title Gift Box API
// @version 1.0
// @description Backend API for Gift Box e-commerce application
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.email support@giftbox.com

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
// @BasePath /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	// Load Configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize Logger
	logger.InitLogger(cfg.Log.Level, cfg.Log.Format)
	logger.Info("Starting Gift Box API...")

	// Connect to Database
	db, err := database.NewPostgresConnection(cfg.Database)
	if err != nil {
		logger.Fatal("Failed to connect to database:", err)
	}
	logger.Info("Database connection established")

	// Get underlying SQL DB for connection management
	sqlDB, err := db.DB()
	if err != nil {
		logger.Fatal("Failed to get database instance:", err)
	}
	defer sqlDB.Close()

	// Set Gin Mode
	gin.SetMode(cfg.Server.Mode)

	// Initialize Router
	router := gin.Default()

	// Health Check Endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "Gift Box API is running",
		})
	})

	// API v1 Group
	v1 := router.Group("/api/v1")
	{
		v1.GET("/ping", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "pong",
			})
		})
	}

	// Start Server
	address := fmt.Sprintf("%s:%s", cfg.Server.Host, cfg.Server.Port)
	logger.Info("Server starting on ", address)

	if err := router.Run(address); err != nil {
		logger.Fatal("Failed to start server:", err)
	}

	logger.Info("Server started on ", address)
}
