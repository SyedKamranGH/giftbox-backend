package config

import (
    "fmt"
    "os"
    "strconv"
    "strings"
    "time"

    "github.com/joho/godotenv"
)

func Load() (*Config, error) {
    // Load .env file
    if err := godotenv.Load(); err != nil {
        // .env is optional in production
        fmt.Println("Warning: .env file not found")
    } 
	
    config := &Config{
        Server: ServerConfig{
            Host: getEnv("SERVER_HOST", "0.0.0.0"),
            Port: getEnv("SERVER_PORT", "8080"),
            Mode: getEnv("GIN_MODE", "debug"),
            Env:  getEnv("APP_ENV", "development"),
        },
        Database: DatabaseConfig{
            Host:            getEnv("DB_HOST", "localhost"),
            Port:            getEnv("DB_PORT", "5432"),
            User:            getEnv("DB_USER", "giftbox_user"),
            Password:        getEnv("DB_PASSWORD", ""),
            DBName:          getEnv("DB_NAME", "giftbox_db"),
            SSLMode:         getEnv("DB_SSLMODE", "disable"),
            MaxOpenConns:    getEnvAsInt("DB_MAX_OPEN_CONNS", 25),
            MaxIdleConns:    getEnvAsInt("DB_MAX_IDLE_CONNS", 5),
            ConnMaxLifetime: getEnvAsDuration("DB_CONN_MAX_LIFETIME", 5*time.Minute),
        },
        JWT: JWTConfig{
            Secret:             getEnv("JWT_SECRET", ""),
            AccessTokenExpiry:  getEnvAsDuration("JWT_ACCESS_TOKEN_EXPIRY", 24*time.Hour),
            RefreshTokenExpiry: getEnvAsDuration("JWT_REFRESH_TOKEN_EXPIRY", 168*time.Hour),
        },
        CORS: CORSConfig{
            AllowedOrigins: strings.Split(getEnv("CORS_ALLOWED_ORIGINS", "http://localhost:3000"), ","),
            AllowedMethods: strings.Split(getEnv("CORS_ALLOWED_METHODS", "GET,POST,PUT,DELETE,OPTIONS"), ","),
            AllowedHeaders: strings.Split(getEnv("CORS_ALLOWED_HEADERS", "Origin,Content-Type,Accept,Authorization"), ","),
        },
        RateLimit: RateLimitConfig{
            Requests: getEnvAsInt("RATE_LIMIT_REQUESTS", 100),
            Duration: getEnvAsDuration("RATE_LIMIT_DURATION", 1*time.Minute),
        },
        Log: LogConfig{
            Level:  getEnv("LOG_LEVEL", "info"),
            Format: getEnv("LOG_FORMAT", "json"),
        },
        Pagination: PaginationConfig{
            DefaultPageSize: getEnvAsInt("DEFAULT_PAGE_SIZE", 10),
            MaxPageSize:     getEnvAsInt("MAX_PAGE_SIZE", 100),
        },
        Upload: UploadConfig{
            MaxSize:           getEnvAsInt64("MAX_UPLOAD_SIZE", 5242880), // 5MB
            AllowedImageTypes: strings.Split(getEnv("ALLOWED_IMAGE_TYPES", "image/jpeg,image/png,image/gif"), ","),
        },
    }

    // Validate required fields
    if config.Database.Password == "" {
        return nil, fmt.Errorf("DB_PASSWORD is required")
    }
    if config.JWT.Secret == "" {
        return nil, fmt.Errorf("JWT_SECRET is required")
    }

    return config, nil
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
    valueStr := getEnv(key, "")
    if value, err := strconv.Atoi(valueStr); err == nil {
        return value
    }
    return defaultValue
}

func getEnvAsInt64(key string, defaultValue int64) int64 {
    valueStr := getEnv(key, "")
    if value, err := strconv.ParseInt(valueStr, 10, 64); err == nil {
        return value
    }
    return defaultValue
}

func getEnvAsDuration(key string, defaultValue time.Duration) time.Duration {
    valueStr := getEnv(key, "")
    if value, err := time.ParseDuration(valueStr); err == nil {
        return value
    }
    return defaultValue
}