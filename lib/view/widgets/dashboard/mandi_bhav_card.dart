import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_text_style.dart';

class MandiBhavCard extends StatelessWidget {
  final List<Map<String, String>> mandiData;
  const MandiBhavCard({required this.mandiData, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MANDI BHAV', style: AppTextStyle.bold18.copyWith(color: AppColors.brown)),
                  const SizedBox(height: 2),
                  Text('Mandi Bhav of popular commodities', style: AppTextStyle.medium14.copyWith(color: AppColors.brown.withOpacity(0.7))),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Text('View all', style: AppTextStyle.medium14.copyWith(color: AppColors.brown, decoration: TextDecoration.underline)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...mandiData.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: i == mandiData.length - 1 ? 0 : 8),
              decoration: BoxDecoration(
                color: AppColors.originalLightOrange,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] ?? '', style: AppTextStyle.bold16.copyWith(color: AppColors.white)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(item['location'] ?? '', style: AppTextStyle.medium14.copyWith(color: Colors.white.withOpacity(0.85))),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: AppColors.brown, size: 18),
                              const SizedBox(width: 2),
                              Text('Price: ', style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                              Text(item['price'] ?? '', style: AppTextStyle.bold16.copyWith(color: AppColors.error)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(item['change'] ?? '', style: AppTextStyle.medium14.copyWith(color: AppColors.error)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
} 