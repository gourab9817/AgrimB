import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a notification to a farmer by writing to 'pending_notifications'.
  Future<bool> sendNotificationToFarmer({
    required String farmerId,
    required String title,
    required String body,
    required NotificationType type,
    required String senderId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Fetch farmer FCM token (for logging/validation, not direct sending)
      final farmerDoc = await _firestore.collection('farmers').doc(farmerId).get();
      if (!farmerDoc.exists) {
        developer.log('NotificationService: Farmer not found: $farmerId');
        return false;
      }
      final farmerData = farmerDoc.data()!;
      final farmerFcmToken = farmerData['fcmToken'];
      if (farmerFcmToken == null) {
        developer.log('NotificationService: Farmer FCM token not found: $farmerId');
        return false;
      }
      // Write notification request to Firestore for backend/Cloud Function
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
      final notification = NotificationModel(
        id: notificationId,
        title: title,
        body: body,
        type: type,
        status: NotificationStatus.unread,
        senderId: senderId,
        receiverId: farmerId,
        data: data,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('pending_notifications').doc(notificationId).set({
        ...notification.toJson(),
        'fcmToken': farmerFcmToken,
      });
      developer.log('NotificationService: Notification request written for farmer $farmerId');
      return true;
    } catch (e, st) {
      developer.log('NotificationService: Failed to send notification: $e', error: e, stackTrace: st);
      return false;
    }
  }

  /// Update the FCM token for the current user in the 'buyers' collection
  static Future<void> updateFcmTokenForCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance.collection('buyers').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error
      print('Failed to update FCM token for current user: $e');
    }
  }
}