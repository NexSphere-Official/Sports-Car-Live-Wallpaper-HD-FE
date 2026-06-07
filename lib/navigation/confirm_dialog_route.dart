import 'package:flutter/material.dart';
import 'app_navigator.dart';

mixin ConfirmDialogRoute {
  Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
  }) async {
    final context = AppNavigator.navigatorKey.currentContext!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  AppNavigator get appNavigator;
}
