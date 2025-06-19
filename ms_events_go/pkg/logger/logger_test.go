package logger

import (
	"log/slog"
	"os"
	"testing"
)

func TestLogger(t *testing.T) {
	logger := NewDefaultLogger("TestLogger", os.Stdout, slog.LevelDebug)
	logger.Info("This is an info message")
	logger.Debug("This is a debug message")
	logger.Error("This is an error message")
	logger.Warning("This is a warning message")
}
