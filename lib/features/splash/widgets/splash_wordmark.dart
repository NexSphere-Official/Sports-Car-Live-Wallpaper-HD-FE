import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

/// The app wordmark block: accent rule, two-line display title with the
/// tail-light-red "LIVE", and a technical tagline.
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    // Soft shadows keep type legible over bright video frames (e.g. the neon
    // light bars) without darkening the footage itself.
    final titleShadows = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.55),
        blurRadius: 18,
        offset: const Offset(0, 2),
      ),
    ];
    final title = GoogleFonts.archivo(
      fontSize: 52,
      fontWeight: FontWeight.w800,
      letterSpacing: -2,
      shadows: titleShadows,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 44, height: 3, color: AppColors.accent),
        const SizedBox(height: 18),
        Text(
          'SPORTS CAR',
          style: title.copyWith(height: 0.92, color: Colors.white),
        ),
        Text(
          'LIVE',
          style: title.copyWith(height: 0.95, color: AppColors.accent),
        ),
        const SizedBox(height: 14),
        Text(
          'LIVE WALLPAPERS  ·  4K MOTION',
          style: GoogleFonts.chakraPetch(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
            color: Colors.white.withValues(alpha: 0.80),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 12,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
