package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct{}

type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
	Token string `json:"token"`
}

// Login godoc
// @Summary      Login user
// @Description  Authenticate user with email and password
// @Tags         Authentication
// @Accept       json
// @Produce      json
// @Param        request body LoginRequest true "Login credentials"
// @Success      200 {object} LoginResponse
// @Failure      400 {object} Response
// @Failure      401 {object} Response
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		BadRequestResponse(c, err.Error())
		return
	}

	// Mock authentication logic
	if req.Email == "test@example.com" && req.Password == "password" {
		c.JSON(http.StatusOK, LoginResponse{Token: "mock-jwt-token"})
		return
	}

	UnauthorizedResponse(c, "Invalid credentials")
}
