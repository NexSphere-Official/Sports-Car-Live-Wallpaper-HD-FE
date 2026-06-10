import 'package:flutter/material.dart';

/// Darkening layers painted over the splash video so foreground type stays
/// legible across any frame of the clip. A vertical gradient protects the top
/// (branding) and bottom (progress) zones while leaving the car visible in the
/// middle, and a soft radial vignette adds cinematic depth and focus.
class SplashScrim extends StatelessWidget {
  const SplashScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.32, 0.52, 0.80, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.40),
                Colors.black.withValues(alpha: 0.12),
                Colors.black.withValues(alpha: 0.52),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.1,
              stops: const [0.55, 1.0],
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
