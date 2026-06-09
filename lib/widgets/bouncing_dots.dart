import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Three dots bouncing in a staggered wave — used for pagination loading.
class BouncingDots extends StatefulWidget {
  const BouncingDots({
    super.key,
    this.color = AppColors.accent,
    this.dotSize = 12,
    this.bounceHeight = 12,
  });

  final Color color;
  final double dotSize;
  final double bounceHeight;

  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  static const _dotCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.dotSize + widget.bounceHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_dotCount, (i) {
              // Stagger each dot a fraction of the cycle apart.
              final phase = (_controller.value + i * 0.18) % 1.0;
              final lift = -widget.bounceHeight * max(0.0, sin(phase * pi));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.translate(
                  offset: Offset(0, lift),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
