package logger

import (
    "os"

    "github.com/sirupsen/logrus"
)

var Log *logrus.Logger

func InitLogger(level, format string) {
    Log = logrus.New()

    // Set log level
    logLevel, err := logrus.ParseLevel(level)
    if err != nil {
        logLevel = logrus.InfoLevel
    }
    Log.SetLevel(logLevel)

    // Set log format
    if format == "json" {
        Log.SetFormatter(&logrus.JSONFormatter{})
    } else {
        Log.SetFormatter(&logrus.TextFormatter{
            FullTimestamp: true,
        })
    }

    Log.SetOutput(os.Stdout)
}

func Info(args ...interface{}) {
    Log.Info(args...)
}

func Debug(args ...interface{}) {
    Log.Debug(args...)
}

func Error(args ...interface{}) {
    Log.Error(args...)
}

func Fatal(args ...interface{}) {
    Log.Fatal(args...)
}

func Warn(args ...interface{}) {
    Log.Warn(args...)
}