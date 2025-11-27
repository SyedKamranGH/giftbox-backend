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

type ErrorResponse struct {
	Error string `json:"error"`
}

// Login godoc
// @Summary      Login user
// @Description  Authenticate user with email and password
// @Tags         Authentication
// @Accept       json
// @Produce      json
// @Param        request body LoginRequest true "Login credentials"
// @Success      200 {object} LoginResponse
// @Failure      400 {object} ErrorResponse
// @Failure      401 {object} ErrorResponse
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Mock authentication logic
	if req.Email == "test@example.com" && req.Password == "password" {
		c.JSON(http.StatusOK, LoginResponse{Token: "mock-jwt-token"})
		return
	}

	c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "Invalid credentials"})
}
