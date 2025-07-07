import 'dart:developer' as developer;
import 'dart:io';

enum LogLevel { debug, info, warning, error }

class Logger {
  static final Logger _instance = Logger._internal();

  factory Logger() => _instance;

  Logger._internal();

  static String name = 'AppLogger';
  static bool enableConsoleLogging = true;
  static LogLevel minLogLevel = LogLevel.debug;

  static final Map<LogLevel, String> _levelColors = {
    LogLevel.debug: '\x1B[34m',   // Синий
    LogLevel.info: '\x1B[32m',    // Зелёный
    LogLevel.warning: '\x1B[33m', // Жёлтый
    LogLevel.error: '\x1B[31m',   // Красный
  };

  static final String _resetColor = '\x1B[0m';

  void configure({
    String? loggerName,
    bool? consoleLogging,
    LogLevel? minimumLevel,
  }) {
    if (loggerName != null) name = loggerName;
    if (consoleLogging != null) enableConsoleLogging = consoleLogging;
    if (minimumLevel != null) minLogLevel = minimumLevel;
  }

  static void log(String message, {LogLevel level = LogLevel.info}) {
    if (level.index < minLogLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();

    // Only use ANSI colors when stdout actually supports them
    final useColor = stdout.supportsAnsiEscapes;
    final color = useColor ? (_levelColors[level] ?? '') : '';
    final reset = useColor ? _resetColor : '';

    final logMessage = '$color[$timestamp][$name][$levelStr] $message$reset';

    if (enableConsoleLogging) {
      if (stdout.hasTerminal) {
        stdout.writeln(logMessage);
      } else {
        developer.log('[$timestamp][$levelStr] $message', name: name);
      }
    }
  }

  void debug(String message) => log(message, level: LogLevel.debug);
  void info(String message) => log(message, level: LogLevel.info);
  void warning(String message) => log(message, level: LogLevel.warning);
  void error(String message) => log(message, level: LogLevel.error);
}
