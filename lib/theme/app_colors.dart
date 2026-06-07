import 'package:flutter/material.dart';

/// Underground-garage palette: layered near-blacks vs. showroom concrete,
/// unified by a single tail-light red accent.
class AppColors {
  AppColors._();

  // Shared accent — the LED tail-light glow.
  static const Color accent = Color(0xFFFF2D3A);
  static const Color accentSoft = Color(0xFFFF5C66);

  // Dark — underground garage.
  static const Color darkBg = Color(0xFF0A0A0C);
  static const Color darkSurface = Color(0xFF141417);
  static const Color darkSurfaceHigh = Color(0xFF1E1E23);
  static const Color darkBorder = Color(0xFF2A2A30);
  static const Color darkText = Color(0xFFF4F4F6);
  static const Color darkTextDim = Color(0xFF9A9AA6);
  static const Color darkTextFaint = Color(0xFF5E5E6A);

  // Light — showroom concrete.
  static const Color lightBg = Color(0xFFF3F2EF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigh = Color(0xFFFAF9F7);
  static const Color lightBorder = Color(0xFFE3E1DC);
  static const Color lightText = Color(0xFF131316);
  static const Color lightTextDim = Color(0xFF5C5C66);
  static const Color lightTextFaint = Color(0xFF9A9AA0);
}
