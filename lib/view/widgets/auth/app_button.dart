import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final String? localizationKey;
  final Color? backgroundColor;
  
  const BasicAppButton({
    required this.onPressed, 
    required this.title, 
    this.localizationKey,
    this.backgroundColor, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // Use localized string if localizationKey is provided, otherwise use the title
    final buttonText = localizationKey != null 
        ? context.l10n(localizationKey!)
        : title;
        
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.orange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Text(buttonText),
      ),
    );
  }
} 