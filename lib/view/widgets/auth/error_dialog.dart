import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ErrorDialog {
  static void show(BuildContext context, {required String message, VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDismiss != null) onDismiss();
            },
            child: const Text('Dismiss', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }
} 