import 'package:flutter/material.dart';
import 'app_navigator.dart';

mixin ErrorDialogRoute {
  void showError(String message) {
    final context = AppNavigator.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  AppNavigator get appNavigator;
}
