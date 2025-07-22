// lib/view/widgets/notifications/custom_notification.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agrimb/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import '../../../core/localization/localization_extension.dart';

enum NotificationType {
  success,
  error,
  info,
  warning,
  comingSoon
}

class CustomNotification {
  static OverlayEntry? _currentOverlayEntry;
  static Timer? _autoHideTimer;

  static void show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    bool showProgress = false,
    double? progress,
  }) {
    // Dismiss any existing notification
    dismiss();

    // Create overlay entry
    _currentOverlayEntry = OverlayEntry(
      builder: (context) => _CustomNotificationWidget(
        message: message,
        type: type,
        title: title,
        onDismiss: () {
          dismiss();
          if (onDismiss != null) {
            onDismiss();
          }
        },
        showProgress: showProgress,
        progress: progress,
      ),
    );

    // Add to overlay
    Overlay.of(context).insert(_currentOverlayEntry!);

    // Auto hide after duration
    _autoHideTimer = Timer(duration, () {
      dismiss();
      if (onDismiss != null) {
        onDismiss();
      }
    });
  }

  static void dismiss() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      message: message,
      type: NotificationType.success,
      title: title ?? context.l10n('success'),
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      message: message,
      type: NotificationType.error,
      title: title ?? context.l10n('error'),
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      message: message,
      type: NotificationType.info,
      title: title ?? context.l10n('information'),
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      message: message,
      type: NotificationType.warning,
      title: title ?? context.l10n('warning'),
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static void showComingSoon({
    required BuildContext context,
    String? title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      message: message ?? context.l10n('this_feature_coming_soon'),
      type: NotificationType.comingSoon,
      title: title ?? context.l10n('coming_soon'),
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static void showProgress({
    required BuildContext context,
    required String message,
    required double progress,
    String? title,
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      message: message,
      type: NotificationType.info,
      title: title,
      duration: const Duration(days: 1), // Long duration as we'll manually dismiss
      onDismiss: onDismiss,
      showProgress: true,
      progress: progress,
    );
  }
}

class _CustomNotificationWidget extends StatefulWidget {
  final String message;
  final String? title;
  final NotificationType type;
  final VoidCallback onDismiss;
  final bool showProgress;
  final double? progress;

  const _CustomNotificationWidget({
    required this.message,
    this.title,
    required this.type,
    required this.onDismiss,
    this.showProgress = false,
    this.progress,
  });

  @override
  State<_CustomNotificationWidget> createState() => _CustomNotificationWidgetState();
}

class _CustomNotificationWidgetState extends State<_CustomNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.comingSoon:
        return AppColors.orange;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.comingSoon:
        return Icons.schedule;
    }
  }

  String? _getLottiePath() {
    switch (widget.type) {
      case NotificationType.success:
        return 'assets/animations/success.json';
      case NotificationType.error:
        return 'assets/animations/error.json';
      case NotificationType.comingSoon:
        return 'assets/animations/coming_soon.json';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.85;
    final lottiePath = _getLottiePath();
    
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              children: [
                // Fullscreen tappable area to dismiss
                Positioned.fill(
                  child: GestureDetector(
                    onTap: widget.onDismiss,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
                
                // Centered notification popup
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Close button at top right
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: widget.onDismiss,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          
                          // Icon or Animation (centered and larger)
                          if (lottiePath != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Lottie.asset(
                                    lottiePath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: _getBackgroundColor().withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIcon(),
                                    color: _getBackgroundColor(),
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Title (centered, larger and bolder)
                          if (widget.title != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                widget.title!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _getBackgroundColor(),
                                ),
                              ),
                            ),
                          
                          // Message (centered and larger)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                          
                          // Progress bar if needed
                          if (widget.showProgress && widget.progress != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 10),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: maxWidth * 0.7,
                                    child: LinearProgressIndicator(
                                      value: widget.progress,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(_getBackgroundColor()),
                                      minHeight: 10,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(widget.progress! * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _getBackgroundColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Action button for coming soon (larger and more prominent)
                          if (widget.type == NotificationType.comingSoon)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: widget.onDismiss,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getBackgroundColor(),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    context.l10n('got_it'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Show Ok button for other types too
                          if (widget.type != NotificationType.comingSoon)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: widget.onDismiss,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getBackgroundColor(),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    context.l10n('ok'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 