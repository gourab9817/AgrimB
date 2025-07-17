import 'package:cloud_firestore/cloud_firestore.dart';

class AcknowledgementCallbackNotificationModel {
  final String id;
  final String acknowledgementId;
  final String body;
  final String buyerFcmToken;
  final String buyerId;
  final int callbackCount;
  final bool callbackRequested;
  final DateTime createdAt;
  final String farmerFcmToken;
  final String farmerId;
  final DateTime? lastCallbackAt;
  final bool markAsRead;
  final String pendingNotificationId;
  final String status;
  final DateTime updatedAt;

  AcknowledgementCallbackNotificationModel({
    required this.id,
    required this.acknowledgementId,
    required this.body,
    required this.buyerFcmToken,
    required this.buyerId,
    required this.callbackCount,
    required this.callbackRequested,
    required this.createdAt,
    required this.farmerFcmToken,
    required this.farmerId,
    this.lastCallbackAt,
    required this.markAsRead,
    required this.pendingNotificationId,
    required this.status,
    required this.updatedAt,
  });

  factory AcknowledgementCallbackNotificationModel.fromJson(Map<String, dynamic> json, String docId) {
    return AcknowledgementCallbackNotificationModel(
      id: docId,
      acknowledgementId: json['acknowledgementId'] ?? '',
      body: json['body'] ?? '',
      buyerFcmToken: json['buyerFcmToken'] ?? '',
      buyerId: json['buyerId'] ?? '',
      callbackCount: json['callbackCount'] ?? 0,
      callbackRequested: json['callbackRequested'] ?? false,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      farmerFcmToken: json['farmerFcmToken'] ?? '',
      farmerId: json['farmerId'] ?? '',
      lastCallbackAt: json['lastCallbackAt'] != null
          ? ((json['lastCallbackAt'] is Timestamp)
              ? (json['lastCallbackAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['lastCallbackAt']))
          : null,
      markAsRead: json['markAsRead'] ?? false,
      pendingNotificationId: json['pendingNotificationId'] ?? '',
      status: json['status'] ?? '',
      updatedAt: (json['updatedAt'] is Timestamp)
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
} 