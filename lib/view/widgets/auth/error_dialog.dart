import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';

class ErrorDialog {
  static void show(BuildContext context, {required String message, VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n('error'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDismiss != null) onDismiss();
            },
            child: Text(context.l10n('dismiss'), style: const TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }
} 