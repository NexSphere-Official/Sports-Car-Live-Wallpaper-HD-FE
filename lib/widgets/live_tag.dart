import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Frosted-glass pill with a tail-light-red play button.
class LiveTag extends StatelessWidget {
  const LiveTag({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dot = compact ? 15.0 : 17.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            compact ? 4 : 5,
            compact ? 4 : 5,
            compact ? 8 : 10,
            compact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: compact ? 11 : 13,
                ),
              ),
              SizedBox(width: compact ? 5 : 7),
              Text(
                'LIVE',
                style: GoogleFonts.chakraPetch(
                  fontSize: compact ? 9 : 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
