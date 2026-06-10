import 'package:flutter/material.dart';
import 'app_navigator.dart';

/// Lightweight, non-blocking feedback. Drives the app-level [ScaffoldMessenger]
/// (wired via [AppNavigator.scaffoldMessengerKey]) so any cubit can surface a
/// snackbar without a local Scaffold context. Colors follow the active theme.
mixin SnackbarRoute {
  void showSnackbar(String message, {bool isError = false}) {
    final messenger = AppNavigator.scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    final scheme = Theme.of(messenger.context).colorScheme;
    final background = isError ? scheme.error : scheme.surfaceContainerHighest;
    final foreground = isError ? scheme.onError : scheme.onSurface;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          elevation: 8,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                color: foreground,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  AppNavigator get appNavigator;
}
