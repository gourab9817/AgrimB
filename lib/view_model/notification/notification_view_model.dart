import 'package:flutter/material.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/acknowledgement_callback_notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository notificationRepository;
  NotificationViewModel(this.notificationRepository);

  String? errorMessage;
  bool isSending = false;

  // Notification list state
  List<NotificationModel> notifications = [];
  bool isLoading = false;

  // Acknowledgement & Callback notification state
  List<AcknowledgementCallbackNotificationModel> callbackNotifications = [];
  List<AcknowledgementCallbackNotificationModel> acknowledgementNotifications = [];
  bool isAckCallbackLoading = false;

  // Load notifications for the current user
  Future<void> loadNotifications({bool refresh = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        notifications = [];
        isLoading = false;
        notifyListeners();
        return;
      }
      final query = await FirebaseFirestore.instance
          .collection('notifications')
          .where('receiverId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      notifications = query.docs.map((doc) => NotificationModel.fromJson(doc.data())).toList();
    } catch (e) {
      errorMessage = 'Failed to load notifications: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  // Load acknowledgement_and_callback notifications for the current user (buyerId)
  Future<void> loadAckCallbackNotifications({bool refresh = false}) async {
    isAckCallbackLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        callbackNotifications = [];
        acknowledgementNotifications = [];
        isAckCallbackLoading = false;
        notifyListeners();
        return;
      }
      final allNotifications = await notificationRepository.fetchAcknowledgementAndCallbackNotifications(
        userId: user.uid,
      );
      
      callbackNotifications = allNotifications.where((n) => n.status == 'callback_requested').toList();
      acknowledgementNotifications = allNotifications.where((n) => n.status == 'acknowledged').toList();
    } catch (e) {
      errorMessage = 'Failed to load acknowledgement/callback notifications: $e';
    }
    isAckCallbackLoading = false;
    notifyListeners();
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).update({
        'status': 'read',
        'readAt': FieldValue.serverTimestamp(),
      });
      final idx = notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        notifications[idx] = NotificationModel(
          id: notifications[idx].id,
          title: notifications[idx].title,
          body: notifications[idx].body,
          type: notifications[idx].type,
          status: NotificationStatus.read,
          senderId: notifications[idx].senderId,
          receiverId: notifications[idx].receiverId,
          data: notifications[idx].data,
          createdAt: notifications[idx].createdAt,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  // Mark an acknowledgement_and_callback notification as read
  Future<void> markAckCallbackNotificationAsRead(String docId) async {
    try {
      await notificationRepository.markAckCallbackNotificationAsRead(docId);
      await loadAckCallbackNotifications();
    } catch (e) {
      errorMessage = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  Future<bool> sendVisitScheduledNotification({
    required String farmerId,
    required String senderId,
    required String cropName,
    required DateTime visitDateTime,
    required String location,
    required String buyerName,
  }) async {
    isSending = true;
    errorMessage = null;
    notifyListeners();
    final title = 'Visit Scheduled';
    final body = '$buyerName scheduled a visit for $cropName on ${visitDateTime.day}/${visitDateTime.month}/${visitDateTime.year} at $location.';
    final data = {
      'cropName': cropName,
      'visitDateTime': visitDateTime.toIso8601String(),
      'location': location,
      'buyerName': buyerName,
    };
    final result = await notificationRepository.sendNotificationToFarmer(
      farmerId: farmerId,
      title: title,
      body: body,
      type: NotificationType.visitScheduled,
      senderId: senderId,
      data: data,
    );
    if (!result) errorMessage = 'Failed to send visit scheduled notification.';
    isSending = false;
    notifyListeners();
    return result;
  }

  Future<bool> sendVisitRescheduledNotification({
    required String farmerId,
    required String senderId,
    required String cropName,
    required DateTime newVisitDateTime,
    required String newLocation,
    required String buyerName,
  }) async {
    isSending = true;
    errorMessage = null;
    notifyListeners();
    final title = 'Visit Rescheduled';
    final body = '$buyerName rescheduled the visit for $cropName to ${newVisitDateTime.day}/${newVisitDateTime.month}/${newVisitDateTime.year} at $newLocation.';
    final data = {
      'cropName': cropName,
      'newVisitDateTime': newVisitDateTime.toIso8601String(),
      'newLocation': newLocation,
      'buyerName': buyerName,
    };
    final result = await notificationRepository.sendNotificationToFarmer(
      farmerId: farmerId,
      title: title,
      body: body,
      type: NotificationType.visitRescheduled,
      senderId: senderId,
      data: data,
    );
    if (!result) errorMessage = 'Failed to send visit rescheduled notification.';
    isSending = false;
    notifyListeners();
    return result;
  }

  Future<bool> sendVisitCancelledNotification({
    required String farmerId,
    required String senderId,
    required String cropName,
    required String buyerName,
  }) async {
    isSending = true;
    errorMessage = null;
    notifyListeners();
    final title = 'Visit Cancelled';
    final body = '$buyerName cancelled the visit for $cropName.';
    final data = {
      'cropName': cropName,
      'buyerName': buyerName,
    };
    final result = await notificationRepository.sendNotificationToFarmer(
      farmerId: farmerId,
      title: title,
      body: body,
      type: NotificationType.visitCancelled,
      senderId: senderId,
      data: data,
    );
    if (!result) errorMessage = 'Failed to send visit cancelled notification.';
    isSending = false;
    notifyListeners();
    return result;
  }

  Future<bool> sendDealFinalizedNotification({
    required String farmerId,
    required String senderId,
    required String cropName,
    required int finalPrice,
    required String buyerName,
  }) async {
    isSending = true;
    errorMessage = null;
    notifyListeners();
    final title = 'Deal Finalized';
    final body = '$buyerName finalized the deal for $cropName at ₹$finalPrice.';
    final data = {
      'cropName': cropName,
      'finalPrice': finalPrice,
      'buyerName': buyerName,
    };
    final result = await notificationRepository.sendNotificationToFarmer(
      farmerId: farmerId,
      title: title,
      body: body,
      type: NotificationType.dealFinalized,
      senderId: senderId,
      data: data,
    );
    if (!result) errorMessage = 'Failed to send deal finalized notification.';
    isSending = false;
    notifyListeners();
    return result;
  }
} 