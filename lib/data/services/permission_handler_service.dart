import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class PermissionHandlerService {
  // Singleton pattern
  static final PermissionHandlerService _instance = PermissionHandlerService._internal();
  factory PermissionHandlerService() => _instance;
  PermissionHandlerService._internal();

  /// Request notification permission (Android 13+/iOS)
  Future<bool> requestNotificationPermission() async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      // Android 13+ requires runtime notification permission
      if (await Permission.notification.isGranted) return true;
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true; // Assume granted for other platforms
  }

  /// Check notification permission status
  Future<bool> isNotificationPermissionGranted() async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  /// Request location permission (foreground only)
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Request background location permission (Android 10+)
  Future<bool> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// Check location permission status (foreground only)
  Future<bool> isLocationPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  /// Check background location permission status
  Future<bool> isBackgroundLocationPermissionGranted() async {
    return await Permission.locationAlways.isGranted;
  }

  // Add more permission methods here (e.g., location, camera, etc.)
} 