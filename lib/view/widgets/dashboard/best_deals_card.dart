import 'package:flutter/material.dart';
import 'package:agrimb/core/constants/app_text_style.dart';
import 'package:agrimb/core/constants/app_spacing.dart';
import '../../../core/localization/localization_extension.dart';

class BestDealsCard extends StatelessWidget {
  final String image;
  final String title;
  final String? localizationKey;
  final VoidCallback? onTap;
  final double height;
  
  const BestDealsCard({
    required this.image,
    required this.title,
    this.localizationKey,
    this.onTap,
    this.height = AppSpacing.bestDealsHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final double size = height * 0.7;
    final responsiveSize = size / (textScaleFactor > 1.3 ? textScaleFactor * 0.8 : 1.0);

    // Use localized string if localizationKey is provided, otherwise use the title
    final cardTitle = localizationKey != null 
        ? context.l10n(localizationKey!)
        : title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsiveSize / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: responsiveSize,
            height: responsiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            width: responsiveSize + 20,
            child: Text(
              cardTitle,
              style: AppTextStyle.medium14.copyWith(color: Colors.orange),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 