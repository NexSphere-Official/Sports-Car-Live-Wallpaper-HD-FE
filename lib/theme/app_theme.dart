import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Industrial-editorial type system:
/// Archivo (display) + Manrope (body) + Chakra Petch (technical labels).
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    bg: AppColors.darkBg,
    surface: AppColors.darkSurface,
    surfaceHigh: AppColors.darkSurfaceHigh,
    border: AppColors.darkBorder,
    text: AppColors.darkText,
    textDim: AppColors.darkTextDim,
    textFaint: AppColors.darkTextFaint,
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    bg: AppColors.lightBg,
    surface: AppColors.lightSurface,
    surfaceHigh: AppColors.lightSurfaceHigh,
    border: AppColors.lightBorder,
    text: AppColors.lightText,
    textDim: AppColors.lightTextDim,
    textFaint: AppColors.lightTextFaint,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceHigh,
    required Color border,
    required Color text,
    required Color textDim,
    required Color textFaint,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accentSoft,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surfaceHigh,
      outline: border,
      error: AppColors.accent,
      onError: Colors.white,
    );

    final display = GoogleFonts.archivo();
    final body = GoogleFonts.manrope();

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.archivo(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        height: 0.98,
        letterSpacing: -1.5,
        color: text,
      ),
      headlineMedium: GoogleFonts.archivo(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: text,
      ),
      titleLarge: GoogleFonts.archivo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        height: 1.5,
        color: textDim,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        height: 1.45,
        color: textDim,
      ),
      labelLarge: GoogleFonts.chakraPetch(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: text,
      ),
      labelMedium: GoogleFonts.chakraPetch(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: textFaint,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme,
      fontFamily: body.fontFamily,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: text),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: text,
        titleTextStyle: display.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: text,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      extensions: [
        AppPalette(
          surfaceHigh: surfaceHigh,
          border: border,
          textDim: textDim,
          textFaint: textFaint,
        ),
      ],
    );
  }
}

/// Extra tokens not covered by [ColorScheme], reachable via
/// `Theme.of(context).extension<AppPalette>()!`.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surfaceHigh,
    required this.border,
    required this.textDim,
    required this.textFaint,
  });

  final Color surfaceHigh;
  final Color border;
  final Color textDim;
  final Color textFaint;

  @override
  AppPalette copyWith({
    Color? surfaceHigh,
    Color? border,
    Color? textDim,
    Color? textFaint,
  }) => AppPalette(
    surfaceHigh: surfaceHigh ?? this.surfaceHigh,
    border: border ?? this.border,
    textDim: textDim ?? this.textDim,
    textFaint: textFaint ?? this.textFaint,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      border: Color.lerp(border, other.border, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
