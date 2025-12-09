package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type Response struct {
	Status  string      `json:"status"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

type PaginationMeta struct {
	Page       int   `json:"page"`
	Limit      int   `json:"limit"`
	TotalItems int64 `json:"total_item"`
	TotalPage  int   `json:"total_page"`
}

type PaginatedResponse struct {
	Status     string         `json:"status"`
	Data       interface{}    `json:"data"`
	Pagination PaginationMeta `json:"pagination"`
}

func SuccessResponse(c *gin.Context, data interface{}){
	c.JSON(http.StatusOK, Response{
		Status: "success",
		Data: data,
	})
}

func SuccessMessageResponse(c *gin.Context, message string){
	c.JSON(http.StatusOK, Response{
		Status: "success",
		Message: message,
	})
}

func CreatedResponse(c *gin.Context, data interface{}){
	c.JSON(http.StatusCreated, Response{
		Status: "created",
		Data: data,
	})
}

func PaginatedSuccessResponse(c *gin.Context, data interface{}, pagination PaginationMeta) {
    c.JSON(http.StatusOK, PaginatedResponse{
        Status:     "success",
        Data:       data,
        Pagination: pagination,
    })
}

func ErrorResponse(c *gin.Context, statusCode int, message string) {
    c.JSON(statusCode, Response{
        Status: "error",
        Error:  message,
    })
}

func BadRequestResponse(c *gin.Context, message string) {
    ErrorResponse(c, http.StatusBadRequest, message)
}

func UnauthorizedResponse(c *gin.Context, message string) {
    ErrorResponse(c, http.StatusUnauthorized, message)
}

func ForbiddenResponse(c *gin.Context, message string) {
    ErrorResponse(c, http.StatusForbidden, message)
}

func NotFoundResponse(c *gin.Context, message string) {
    ErrorResponse(c, http.StatusNotFound, message)
}

func InternalServerErrorResponse(c *gin.Context, message string) {
    ErrorResponse(c, http.StatusInternalServerError, message)
}

func ValidationErrorResponse(c *gin.Context, errors interface{}) {
    c.JSON(http.StatusBadRequest, gin.H{
        "status": "error",
        "error":  "Validation failed",
        "details": errors,
    })
}