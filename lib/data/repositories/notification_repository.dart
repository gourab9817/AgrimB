import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/acknowledgement_callback_notification_model.dart';

class NotificationRepository {
  final NotificationService _notificationService;
  NotificationRepository(this._notificationService);

  Future<bool> sendNotificationToFarmer({
    required String farmerId,
    required String title,
    required String body,
    required NotificationType type,
    required String senderId,
    Map<String, dynamic>? data,
  }) async {
    return await _notificationService.sendNotificationToFarmer(
      farmerId: farmerId,
      title: title,
      body: body,
      type: type,
      senderId: senderId,
      data: data,
    );
  }

  // Fetch notifications from acknowledgement_and_callback collection
  Future<List<AcknowledgementCallbackNotificationModel>> fetchAcknowledgementAndCallbackNotifications({required String userId}) async {
    final collection = FirebaseFirestore.instance.collection('acknowledgement_and_callback');
    final query = await collection
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs
        .map((doc) => AcknowledgementCallbackNotificationModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Mark acknowledgement_and_callback notification as read
  Future<void> markAckCallbackNotificationAsRead(String docId) async {
    final docRef = FirebaseFirestore.instance.collection('acknowledgement_and_callback').doc(docId);
    await docRef.update({'markAsRead': true});
  }
} 