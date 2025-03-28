import 'package:flutter/material.dart';

import '../colors.dart';

const fontFamily = "Lato";

final colorScheme = ColorScheme(
  primary: purple,
  // основной цвет
  secondary: brown,
  // вторичный цвет
  surface: Colors.white,
  // цвет фона поверх элементов
  error: red,
  // цвет ошибки
  onPrimary: black,
  // цвет текста на основном фоне
  onSecondary: black,
  // цвет текста на вторичном фоне
  onSurface: black,
  // цвет текста на поверхности
  onError: gray,
  // цвет текста на фоне ошибки
  brightness: Brightness.light, // светлая тема
);

final textTheme = TextTheme(
  headlineMedium: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
  bodyMedium: TextStyle(fontSize: 16.0),
  bodySmall: TextStyle(fontSize: 14.0),
  labelMedium: TextStyle(fontSize: 10),
);

var lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: fontFamily,
  colorScheme: colorScheme,
  textTheme: textTheme,
  buttonTheme: ButtonThemeData(buttonColor: gray, textTheme: ButtonTextTheme.primary),
  iconTheme: IconThemeData(color: Colors.white.withOpacity(0.6), size: 24.0),
);
