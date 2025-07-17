import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/notification_model.dart';
import '../../../view_model/notification/notification_view_model.dart';
import '../../../data/models/acknowledgement_callback_notification_model.dart';
import '../../../core/theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      final viewModel = Provider.of<NotificationViewModel>(context, listen: false);
      viewModel.loadNotifications(refresh: true);
      viewModel.loadAckCallbackNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Notifications', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brown),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange,
          labelColor: AppColors.orange,
          unselectedLabelColor: AppColors.brown,
          labelStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Callback'),
          ],
        ),
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Acknowledgement notifications
              RefreshIndicator(
                color: AppColors.orange,
                backgroundColor: AppColors.white,
                onRefresh: () async => await viewModel.loadAckCallbackNotifications(),
                child: viewModel.isAckCallbackLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                    : viewModel.acknowledgementNotifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/no_data_found.png', width: 120, height: 120, fit: BoxFit.contain),
                                const SizedBox(height: 16),
                                Text(
                                  'No acknowledgement notifications yet.',
                                  style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.brown),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            itemCount: viewModel.acknowledgementNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = viewModel.acknowledgementNotifications[index];
                              return AckCallbackNotificationCard(notification: notification);
                            },
                          ),
              ),
              // Callback notifications
              RefreshIndicator(
                color: AppColors.orange,
                backgroundColor: AppColors.white,
                onRefresh: () async => await viewModel.loadAckCallbackNotifications(),
                child: viewModel.isAckCallbackLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                    : viewModel.callbackNotifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/no_data_found.png', width: 120, height: 120, fit: BoxFit.contain),
                                const SizedBox(height: 16),
                                Text(
                                  'No callback notifications yet.',
                                  style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.brown),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            itemCount: viewModel.callbackNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = viewModel.callbackNotifications[index];
                              return AckCallbackNotificationCard(notification: notification);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  const NotificationCard({Key? key, required this.notification, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    final theme = Theme.of(context);
    return Card(
      color: isUnread ? theme.colorScheme.primary.withOpacity(0.08) : Colors.white,
      elevation: isUnread ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(_iconForType(notification.type), color: isUnread ? theme.colorScheme.primary : Colors.grey, size: 32),
        title: Text(notification.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            : null,
      ),
    );
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.visitScheduled:
        return Icons.event_available;
      case NotificationType.visitRescheduled:
        return Icons.update;
      case NotificationType.visitCancelled:
        return Icons.cancel;
      case NotificationType.dealFinalized:
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class AckCallbackNotificationCard extends StatelessWidget {
  final AcknowledgementCallbackNotificationModel notification;
  const AckCallbackNotificationCard({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<NotificationViewModel>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth < 400 ? 10.0 : 18.0;
    final cardRadius = screenWidth < 400 ? 14.0 : 20.0;
    final iconSize = screenWidth < 400 ? 28.0 : 36.0;
    final buttonFontSize = screenWidth < 400 ? 12.0 : 14.0;
    // Determine heading based on status
    String heading = 'Notification';
    if (notification.status == 'acknowledged') {
      heading = 'Acknowledgement';
    } else if (notification.status == 'callback_requested') {
      heading = 'Callback Request';
    }
    return Card(
      color: notification.markAsRead ? AppColors.white : AppColors.lightOrange,
      elevation: notification.markAsRead ? 1 : 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: cardPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      shadowColor: AppColors.shadow,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notifications, color: notification.markAsRead ? AppColors.orange : AppColors.grey, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(heading, style: theme.textTheme.titleMedium?.copyWith(fontWeight: notification.markAsRead ? FontWeight.normal : FontWeight.bold, color: AppColors.brown)),
                      const SizedBox(height: 4),
                      Text(notification.body, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(_formatTime(notification.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                      if (notification.callbackRequested)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Callback requested', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.orange, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                if (!notification.markAsRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: buttonFontSize),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await viewModel.markAckCallbackNotificationAsRead(notification.id);
                      },
                      child: const Text('Mark as read'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            notification.markAsRead
                ? Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 4),
                      Text('Read', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success)),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${time.day}/${time.month}/${time.year}';
  }
} 