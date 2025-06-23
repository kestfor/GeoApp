package logger

import (
	"io"
	"log"
	"log/slog"
	time2 "time"
)

type Logger interface {
	Log(level slog.Level, message string)
	Info(message string)
	Debug(message string)
	Error(message string)
	Warning(message string)
}

const (
	colorReset  = "\x1b[0m"
	colorRed    = "\x1b[31m"
	colorGreen  = "\x1b[32m"
	colorYellow = "\x1b[33m"
	colorBlue   = "\x1b[34m"
	colorPurple = "\x1b[35m"
	colorCyan   = "\x1b[36m"
	colorWhite  = "\x1b[37m"
)

type DefaultLogger struct {
	logger   *log.Logger
	logLevel slog.Level
	prefix   string
}

func NewDefaultLogger(prefix string, out io.Writer, logLevel slog.Level) *DefaultLogger {
	return &DefaultLogger{
		logger:   log.New(out, "", 0),
		logLevel: logLevel,
		prefix:   prefix,
	}
}

func getColor(level slog.Level) string {
	switch level {
	case slog.LevelDebug:
		return colorBlue
	case slog.LevelInfo:
		return colorGreen
	case slog.LevelWarn:
		return colorYellow
	case slog.LevelError:
		return colorRed
	default:
		return colorWhite
	}
}

func (logger *DefaultLogger) SetLogLevel(level slog.Level) {
	logger.logLevel = level
}

func (logger *DefaultLogger) Log(level slog.Level, message string) {
	if level < logger.logLevel {
		return
	}
	color := getColor(level)
	time := time2.Now()
	time.Format("2006-01-02 15:04:05")
	// Prefix from l.logger will include date/time and any custom prefix
	logger.logger.Printf("%s[%s][%s][%s] %s%s", color, logger.prefix, time.String(), level.String(), message, colorReset)
}

func (logger *DefaultLogger) Info(message string) {
	logger.Log(slog.LevelInfo, message)
}

func (logger *DefaultLogger) Debug(message string) {
	logger.Log(slog.LevelDebug, message)
}

func (logger *DefaultLogger) Error(message string) {
	logger.Log(slog.LevelError, message)
}

func (logger *DefaultLogger) Warning(message string) {
	logger.Log(slog.LevelWarn, message)
}
