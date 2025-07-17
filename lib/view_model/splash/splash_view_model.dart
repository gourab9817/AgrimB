import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/permission_handler_service.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> initializeApp(BuildContext context) async {
    try {
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
            title: const Text('Enable Notifications'),
            content: const Text('Notifications help you stay updated with important information. Please enable notification permissions in your device settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
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
            title: const Text('Enable Location'),
            content: const Text('Location access is required for app features like weather, maps, and more. Please enable location permissions in your device settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      _isInitialized = true;
      notifyListeners();

      // Check if user is logged in
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
      debugPrint('Error initializing app: $e');
      // Handle initialization error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize app. Please try again.'),
          ),
        );
      }
    }
  }
} 