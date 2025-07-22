import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? titleLocalizationKey;
  final String? subtitleLocalizationKey;
  
  const AuthHeader({
    required this.title, 
    required this.subtitle, 
    this.titleLocalizationKey,
    this.subtitleLocalizationKey,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // Use localized strings if keys are provided, otherwise use the provided text
    final headerTitle = titleLocalizationKey != null 
        ? context.l10n(titleLocalizationKey!)
        : title;
        
    final headerSubtitle = subtitleLocalizationKey != null 
        ? context.l10n(subtitleLocalizationKey!)
        : subtitle;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerTitle,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.originalBrown,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          headerSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
} 