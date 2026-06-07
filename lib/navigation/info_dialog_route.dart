import 'package:flutter/material.dart';
import 'app_navigator.dart';

mixin InfoDialogRoute {
  void showInfo(String title, String message) {
    final context = AppNavigator.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  AppNavigator get appNavigator;
}
