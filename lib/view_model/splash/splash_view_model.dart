import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/permission_handler_service.dart';
import '../../core/localization/app_localizations.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> initializeApp(BuildContext context) async {
    try {
      // Load default language first
      await AppLocalizations.loadLanguage();
      
      // Add your initialization logic here
      // For example:
      // - Check user authentication
      // - Load necessary data
      // - Initialize services
      
      // Simulate some loading time
      await Future.delayed(const Duration(seconds: 2));
      
      // Request notification permission
      final permissionGranted = await PermissionHandlerService().requestNotificationPermission();
      if (!permissionGranted && context.mounted) {
        // Show rationale dialog if permission denied
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.getString('enable_notifications')),
            content: Text(AppLocalizations.getString('notifications_help_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(AppLocalizations.getString('ok')),
              ),
            ],
          ),
        );
      }

      // Request location permission
      final locationGranted = await PermissionHandlerService().requestLocationPermission();
      if (!locationGranted && context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.getString('enable_location')),
            content: Text(AppLocalizations.getString('location_required_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(AppLocalizations.getString('ok')),
              ),
            ],
          ),
        );
      }
      
      _isInitialized = true;
      notifyListeners();

      // Always show language selection screen first
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.languageSelection);
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Handle initialization error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.getString('failed_to_initialize')),
          ),
        );
      }
    }
  }

  // Method to proceed to main app after language selection
  Future<void> proceedToMainApp(BuildContext context) async {
    try {
      // Check user authentication status
      final user = await _localStorageService.getUserData();
      
      if (context.mounted) {
        if (user != null) {
          if (user.profileVerified) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profileVerification);
          }
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('Error proceeding to main app: $e');
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }
} 