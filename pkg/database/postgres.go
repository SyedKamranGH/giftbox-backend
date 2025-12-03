package database

import (
    "fmt"
    "log"
    "time"

    "github.com/SyedKamranGH/giftbox-backend/internal/config"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
)

func NewPostgresConnection(cfg config.DatabaseConfig) (*gorm.DB, error) {
    dsn := fmt.Sprintf(
        "host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
        cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.DBName, cfg.SSLMode,
    )

    // Configure GORM logger
    gormConfig := &gorm.Config{
        Logger: logger.Default.LogMode(logger.Info),
        NowFunc: func() time.Time {
            return time.Now().UTC()
        },
    }

    db, err := gorm.Open(postgres.Open(dsn), gormConfig)
    if err != nil {
        return nil, fmt.Errorf("failed to connect to database: %w", err)
    }

    sqlDB, err := db.DB()
    if err != nil {
        return nil, fmt.Errorf("failed to get database instance: %w", err)
    }

    // Set connection pool settings
    sqlDB.SetMaxOpenConns(cfg.MaxOpenConns)
    sqlDB.SetMaxIdleConns(cfg.MaxIdleConns)
    sqlDB.SetConnMaxLifetime(cfg.ConnMaxLifetime)

    // Test connection
    if err := sqlDB.Ping(); err != nil {
        return nil, fmt.Errorf("failed to ping database: %w", err)
    }

    log.Println("✅ Database connection established successfully")
    return db, nil
}