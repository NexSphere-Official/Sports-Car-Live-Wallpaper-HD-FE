import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

/// Small studio attribution chip pinned to the top of the splash.
class SplashBrandBadge extends StatelessWidget {
  const SplashBrandBadge({super.key, this.label = 'NexSphere'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.chakraPetch(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}
