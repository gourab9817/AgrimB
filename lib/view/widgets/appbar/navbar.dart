import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/popup/custom_notification.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 20) / 4;
    return Container(
      height: 64,
      margin: EdgeInsets.fromLTRB(10, 0, 10, MediaQuery.of(context).viewPadding.bottom + 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            label: 'Home',
            assetPath: AppAssets.homeicon,
            isSelected: currentIndex == 0,
            itemWidth: itemWidth,
            onTap: () => _handleNavigation(context, 0),
          ),
          _buildNavItem(
            context: context,
            index: 1,
            label: 'Buy',
            assetPath: AppAssets.buyicon,
            isSelected: currentIndex == 1,
            itemWidth: itemWidth,
            onTap: () => _handleNavigation(context, 1),
          ),
          _buildNavItem(
            context: context,
            index: 2,
            label: 'Calls',
            assetPath: AppAssets.phone,
            isSelected: currentIndex == 2,
            itemWidth: itemWidth,
            onTap: () => _handleNavigation(context, 2),
          ),
          _buildNavItem(
            context: context,
            index: 3,
            label: 'Profile',
            assetPath: AppAssets.userprofileicon,
            isSelected: currentIndex == 3,
            itemWidth: itemWidth,
            onTap: () => _handleNavigation(context, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required String assetPath,
    required bool isSelected,
    required double itemWidth,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SvgPicture.asset(
              assetPath,
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.orange : AppColors.brown,
                BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.orange : AppColors.brown,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.buy, (route) => false);
        break;
      case 2:
        CustomNotification.showComingSoon(
          context: context,
          message: 'Calls feature is coming soon!',
        );
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.profile, (route) => false);
        break;
    }
  }
} 