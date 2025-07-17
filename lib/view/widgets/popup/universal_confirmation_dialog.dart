import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/app_colors.dart';

class UniversalConfirmationDialog extends StatelessWidget {
  final String animationAsset;
  final String message;
  final String yesText;
  final String noText;
  final VoidCallback onYes;
  final VoidCallback? onNo;
  final Color? yesColor;
  final Color? noColor;
  final Color? yesTextColor;
  final Color? noTextColor;

  const UniversalConfirmationDialog({
    Key? key,
    required this.animationAsset,
    required this.message,
    required this.yesText,
    required this.noText,
    required this.onYes,
    this.onNo,
    this.yesColor,
    this.noColor,
    this.yesTextColor,
    this.noTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(animationAsset, width: 150, repeat: false),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyle.bold18.copyWith(color: AppColors.brown),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: noColor ?? AppColors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onNo != null) onNo!();
                    },
                    child: Text(noText, style: AppTextStyle.bold16.copyWith(color: noTextColor ?? AppColors.grey)),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yesColor ?? AppColors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onYes();
                    },
                    child: Text(yesText, style: AppTextStyle.bold16.copyWith(color: yesTextColor ?? AppColors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 