import 'package:flutter/material.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class FeatureCard extends StatelessWidget {
  final VoidCallback? onTap;
  const FeatureCard({
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 400 ? constraints.maxWidth : 380.0;
        final height = width * 0.52;
        return Center(
          child: Container(
            width: width,
            height: height,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.orange.withOpacity(0.18), width: 1.5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    AppAssets.buy_feature_image,
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.orange.withOpacity(0.55),
                          AppColors.lightOrange.withOpacity(0.45),
                          Colors.white.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(26, 28, 26, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy Crop',
                        style: AppTextStyle.bold24.copyWith(
                          color: AppColors.brown,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 4,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'List your crops, set your price, and\nstart sell your price.',
                        style: AppTextStyle.medium16.copyWith(
                          color: AppColors.brown.withOpacity(0.92),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.orange.withOpacity(0.32),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                minimumSize: const Size(0, 38),
                                elevation: 0,
                              ),
                              onPressed: onTap,
                              child: const Text(
                                'Buy Crop',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 