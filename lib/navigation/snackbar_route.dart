import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'app_navigator.dart';

/// Lightweight, non-blocking feedback styled as an instrument-cluster readout:
/// a frosted near-black pill with a glowing leading status lamp. Success glows
/// tail-light red; attention/error glows caution amber so the two never blur.
/// Drives the app-level [ScaffoldMessenger] (via [AppNavigator.scaffoldMessengerKey])
/// so any cubit can surface a snackbar without a local Scaffold context.
mixin SnackbarRoute {
  void showSnackbar(String message, {bool isError = false}) {
    final messenger = AppNavigator.scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    final status = isError ? AppColors.caution : AppColors.accent;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: _SnackContent(message: message, status: status, isError: isError),
        ),
      );
  }

  AppNavigator get appNavigator;
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({
    required this.message,
    required this.status,
    required this.isError,
  });

  final String message;
  final Color status;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            // Always the instrument-panel dark, regardless of app theme.
            color: AppColors.darkSurfaceHigh.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The status lamp: a glowing vertical bar.
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: status,
                    boxShadow: [
                      BoxShadow(
                        color: status.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 16, 13),
                    child: Row(
                      children: [
                        Icon(
                          isError
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_rounded,
                          color: status,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: GoogleFonts.manrope(
                              color: AppColors.darkText,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
