import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/style/colors.dart';

final mainGradientLight = LinearGradient(
  stops: [0.1, 0.5],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xff7F4ABF), lightGrayWithPurple],
);

ThemeData buildAppTheme() {
  // Базовая схема цветов, здесь можно использовать вашу seed-цветовую палитру.
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: Color(0xff9575CD),
    brightness: Brightness.light, // или Brightness.dark для тёмного режима
  );

  // Новый TextTheme с использованием стилей Lato.
  final TextTheme textTheme = TextTheme(
    // Заголовок: 24 pt, Bold (используется как основной заголовок)
    headlineLarge: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
    // Можно настроить и другие headline-стили, если требуется:
    headlineMedium: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
    headlineSmall: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onBackground),

    // Основной текст: 16 pt
    bodyMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.normal, color: colorScheme.onBackground),

    // Подписи и мелкий текст: 14 pt
    bodySmall: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: colorScheme.onBackground.withOpacity(0.8),
    ),

    // Остальные стили можно настроить по необходимости:
    titleLarge: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
    titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
    titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
    labelLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onBackground),
    labelMedium: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onBackground),
    labelSmall: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onBackground),
    displayLarge: GoogleFonts.lato(fontSize: 30, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
    displayMedium: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
    displaySmall: GoogleFonts.lato(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: lightGrayWithPurple,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.black,
      titleTextStyle: textTheme.headlineLarge,
    ),
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: colorScheme.onSecondary.withOpacity(0.05),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      hintStyle: GoogleFonts.lato(fontSize: 16, color: colorScheme.onBackground.withOpacity(0.6)),
      labelStyle: GoogleFonts.lato(fontSize: 16, color: colorScheme.onBackground),
    ),
    // cardTheme: CardTheme(
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //   ),
    //   color: colorScheme.surface,
    //   margin: const EdgeInsets.all(8),
    // ),
  );
}
