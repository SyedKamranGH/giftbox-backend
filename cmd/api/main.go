package main

import (
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	_ "github.com/SyedKamranGH/giftbox-backend/docs" // Import generated docs
	"github.com/SyedKamranGH/giftbox-backend/internal/handler"
)

// @title           Gift Box API
// @version         1.0
// @description     Backend API for Gift Box e-commerce application
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.email  support@giftbox.com

// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html

// @host      localhost:8080
// @BasePath  /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	router := gin.Default()

	authHandler := &handler.AuthHandler{}

	v1 := router.Group("/api/v1")
	{
		auth := v1.Group("/auth")
		{
			auth.POST("/login", authHandler.Login)
		}
	}

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	router.Run(":8080")
}
