import 'package:flutter/material.dart';

/// Staggered fade + upward slide for a single intro layer. [start] is the
/// fraction of the shared [controller] timeline at which this child begins to
/// reveal, so multiple [SplashReveal]s cascade off one controller.
class SplashReveal extends StatelessWidget {
  const SplashReveal({
    super.key,
    required this.controller,
    required this.start,
    required this.child,
  });

  final Animation<double> controller;
  final double start;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, (start + 0.6).clamp(0.0, 1.0)),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, animatedChild) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - animation.value)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
