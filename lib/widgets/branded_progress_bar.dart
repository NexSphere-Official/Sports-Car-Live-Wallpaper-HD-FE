import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A thin, glowing determinate progress bar. The fill animates smoothly toward
/// each new [value] (0.0–1.0) so callers can emit coarse step targets and let
/// the bar interpolate. Styled as a lit strip riding a dim track — the LED
/// tail-light language used across the app.
class BrandedProgressBar extends StatelessWidget {
  const BrandedProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.accent,
    this.trackColor,
    this.height = 4,
    this.duration = const Duration(milliseconds: 650),
  });

  /// Target progress, clamped to 0.0–1.0.
  final double value;
  final Color color;
  final Color? trackColor;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final track = trackColor ?? Colors.white.withValues(alpha: 0.12);
    final radius = BorderRadius.circular(height);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: track, borderRadius: radius),
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            return FractionallySizedBox(
              widthFactor: t == 0 ? 0.0001 : t,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.65), color],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.55),
                      blurRadius: 12,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
