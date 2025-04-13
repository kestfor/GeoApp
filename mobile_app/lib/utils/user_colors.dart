import 'dart:ui';

import 'package:flutter/cupertino.dart';

Color getUserColor(String userId) {
  int hash = userId.hashCode;

  final double hue = (hash % 360).toDouble();

  const double saturation = 0.5;
  const double lightness = 0.8;

  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}

LinearGradient getUserGradient(String userId) {
  int hash = userId.hashCode;

  final double baseHue = (hash % 360).toDouble();

  const double saturation = 0.5;
  const double lightness = 0.8;

  final HSLColor hslColor1 =
  HSLColor.fromAHSL(1.0, baseHue, saturation, lightness);

  final HSLColor hslColor2 =
  HSLColor.fromAHSL(1.0, (baseHue + 80) % 360, saturation, lightness);

  return LinearGradient(
    colors: [hslColor1.toColor(), hslColor2.toColor()],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}