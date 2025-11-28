package config

import (
	"time"
)

type Config struct {
	Server     ServerConfig
	Database   DatabaseConfig
	JWT        JWTConfig
	CORS       CORSConfig
	RateLimit  RateLimitConfig
	Log        LogConfig
	Pagination PaginationConfig
	Upload     UploadConfig
}

type ServerConfig struct {
	Host string
	Port string
	Mode string
	Env  string
}

type DatabaseConfig struct {
	Host            string
	Port            string
	User            string
	Password        string
	DBName          string
	SSLMode         string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
}

type JWTConfig struct {
	Secret             string
	AccessTokenExpiry  time.Duration
	RefreshTokenExpiry time.Duration
}

type CORSConfig struct {
	AllowedOrigins []string
	AllowedMethods []string
	AllowedHeaders []string
}

type RateLimitConfig struct {
	Requests int
	Duration time.Duration
}

type LogConfig struct {
	Level  string
	Format string
}

type PaginationConfig struct {
	DefaultPageSize int
	MaxPageSize     int
}

type UploadConfig struct {
	MaxSize           int64
	AllowedImageTypes []string
}
