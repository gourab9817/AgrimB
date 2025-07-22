import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../view_model/profile/profile_view_model.dart';
import '../../../view_model/notification/notification_view_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/localization/localization_extension.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  String getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, dd MMM yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final userName = profileViewModel.user?.name ?? 'Farmer';
    
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 253, 248, 248),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 252, 190, 96), // Pure orange (left)
              Color.fromARGB(255, 247, 181, 82), // Light orange
              Color.fromARGB(255, 255, 194, 102), // Lighter orange
              Color.fromARGB(255, 255, 195, 106), // Very light orange (right)
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(MediaQuery.of(context).size.width * 0.08), // More curved radius
            bottomRight: Radius.circular(MediaQuery.of(context).size.width * 0.08), // More curved radius
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.l10n('namaste')} $userName',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color.fromARGB(255, 96, 63, 28),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
          ),
          Row(
            children: [
              Text(
                getFormattedDate(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 61, 41, 9),
                      fontSize: 18,
                    ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Color(0xFFFFA726), size: 24),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 8.0),
          child: Row(
            children: [
              // Notification icon with badge
              Consumer<NotificationViewModel>(
                builder: (context, notificationViewModel, child) {
                  final unreadCount = notificationViewModel.notifications.where((n) => n.isUnread).length;
                  final screenWidth = MediaQuery.of(context).size.width;
                  final iconSize = screenWidth < 400 ? 28.0 : 36.0;
                  final badgeFontSize = screenWidth < 400 ? 10.0 : 14.0;
                  final badgeSize = screenWidth < 400 ? 16.0 : 22.0;
                  return Stack(
                clipBehavior: Clip.none,
                children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.notifications,
                              color: Colors.black,
                              size: iconSize,
                              semanticLabel: 'Notifications',
                            ),
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                            constraints: BoxConstraints(
                              minWidth: badgeSize,
                              minHeight: badgeSize,
                      ),
                            child: Center(
                        child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                                  fontSize: badgeFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                                semanticsLabel: 'Unread notifications: $unreadCount',
                        ),
                      ),
                    ),
                  ),
                ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
} 