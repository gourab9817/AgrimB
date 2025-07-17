// view/widgets/Button/app_button.dart
import 'package:flutter/material.dart';
import 'package:agrimb/core/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback? onPressed; // Changed to nullable
  final String title;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const BasicAppButton({
    Key? key,
    required this.onPressed,
    required this.title,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = width ?? constraints.maxWidth;
        // Cap the width for large screens
        if (width == null && buttonWidth > 400) {
          buttonWidth = 400;
        }
        return SizedBox(
          width: buttonWidth,
          height: height ?? 50,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.orange,
              foregroundColor: textColor ?? AppColors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.brown,
              ),
            ),
          ),
        );
      },
    );
  }
}