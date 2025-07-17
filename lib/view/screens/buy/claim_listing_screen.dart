import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/listing_model.dart';
import '../../widgets/appbar/navbar.dart';
import '../../../routes/app_routes.dart';

class ClaimListingScreen extends StatelessWidget {
  final ListingModel listing;
  const ClaimListingScreen({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Claim listing', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.l),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minWidth: 280,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: AspectRatio(
                        aspectRatio: 2.2,
                        child: Image.network(
                          listing.imagePath,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              listing.name.toUpperCase(),
                              style: AppTextStyle.bold20.copyWith(color: AppColors.brown),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.inventory_2, color: AppColors.grey, size: 20),
                              const SizedBox(width: 6),
                              Text('Quantity : ', style: AppTextStyle.medium14.copyWith(color: AppColors.grey)),
                              Text('${listing.quantity} quintals', style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.grade, color: AppColors.orange, size: 20),
                              const SizedBox(width: 6),
                              Text('Quality : ', style: AppTextStyle.medium14.copyWith(color: AppColors.orange)),
                              Text(listing.quality, style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: AppColors.success, size: 20),
                              const SizedBox(width: 6),
                              Text('Offered Price: ', style: AppTextStyle.medium14.copyWith(color: AppColors.success)),
                              Text('₹${listing.price}/quintal', style: AppTextStyle.medium14.copyWith(color: AppColors.success)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.build, color: AppColors.grey, size: 20),
                              const SizedBox(width: 6),
                              Text('Quality indicator: ', style: AppTextStyle.medium14.copyWith(color: AppColors.grey)),
                              Text(listing.qualityIndicator, style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (listing.description.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.description, color: AppColors.brown, size: 20),
                                const SizedBox(width: 6),
                                Text('Description: ', style: AppTextStyle.medium14.copyWith(color: AppColors.brown)),
                                Expanded(
                                  child: Text(
                                    listing.description,
                                    style: AppTextStyle.medium14.copyWith(color: AppColors.textSecondary),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 2),
                              Text('Listing Date : ', style: AppTextStyle.medium14.copyWith(color: AppColors.error)),
                              Text(listing.listingDate, style: AppTextStyle.medium14.copyWith(color: AppColors.error)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.originalOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.visitSchedule,
                                  arguments: listing,
                                );
                              },
                              child: Text('Claim Listing', style: AppTextStyle.bold16.copyWith(color: AppColors.brown)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
} 