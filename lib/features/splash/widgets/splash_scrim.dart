import 'package:flutter/material.dart';

/// Darkening gradient painted over the splash video so the foreground type
/// stays legible across any frame of the clip.
class SplashScrim extends StatelessWidget {
  const SplashScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.35),
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.55),
            Colors.black.withValues(alpha: 0.88),
          ],
          stops: const [0.0, 0.35, 0.72, 1.0],
        ),
      ),
    );
  }
}
