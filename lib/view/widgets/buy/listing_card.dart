import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

class ListingCard extends StatelessWidget {
  final String imageUrl;
  final String cropName;
  final String location;
  final String quantity;
  final String listingDate;
  final VoidCallback onClaim;
  final VoidCallback? onTap;
  final bool isClaimed;
  final String? visitStatus;

  const ListingCard({
    Key? key,
    required this.imageUrl,
    required this.cropName,
    required this.location,
    required this.quantity,
    required this.listingDate,
    required this.onClaim,
    this.onTap,
    required this.isClaimed,
    this.visitStatus,
  }) : super(key: key);

  Color _getStatusColor() {
    if (visitStatus == null) return AppColors.brown;
    switch (visitStatus!.toLowerCase()) {
      case 'pending':
        return AppColors.blue;
      case 'rescheduled and pending':
        return AppColors.lightBlue;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.brown;
    }
  }

  String getFullImageUrl() {
    // If the imageUrl is a full Firebase Storage URL
    if (imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      return imageUrl;
    }
    // If the imageUrl is a gs:// URL, convert to download URL
    if (imageUrl.startsWith('gs://')) {
      final fileName = imageUrl.split('/').last;
      return 'https://firebasestorage.googleapis.com/v0/b/agritech-fbd5e.appspot.com/o/crops%2F$fileName?alt=media';
    }
    // If the imageUrl is a local file path, extract the filename
    if (imageUrl.contains('/')) {
      final fileName = imageUrl.split('/').last;
      return 'https://firebasestorage.googleapis.com/v0/b/agritech-fbd5e.appspot.com/o/crops%2F$fileName?alt=media';
    }
    // If only the filename is stored
    return 'https://firebasestorage.googleapis.com/v0/b/agritech-fbd5e.appspot.com/o/crops%2F${Uri.encodeComponent(imageUrl)}?alt=media';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: getFullImageUrl(),
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/agritech-fbd5e.appspot.com/o/crops%2Fno_data_found.png?alt=media',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.orange, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.brown,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.scale, size: 16, color: AppColors.brown),
                      const SizedBox(width: 4),
                      Text(
                        'Quantity : ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.brown,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      Flexible(
                        child: Text(
                          quantity,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Listing Date : $listingDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          cropName.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: isClaimed ? null : onClaim,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _getStatusColor(), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          isClaimed ? (visitStatus ?? 'Already Claimed') : 'Claim listing',
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
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
  }
} 