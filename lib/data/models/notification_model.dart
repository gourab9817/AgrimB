import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of notifications supported in the system.
enum NotificationType {
  visitScheduled,
  visitRescheduled,
  visitCancelled,
  dealFinalized,
  general,
}

enum NotificationStatus {
  unread,
  read,
  failed,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationStatus status;
  final String senderId;
  final String receiverId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.status,
    required this.senderId,
    required this.receiverId,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.general,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString() == 'NotificationStatus.${json['status']}',
        orElse: () => NotificationStatus.unread,
      ),
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      readAt: json['readAt'] != null
          ? ((json['readAt'] is Timestamp)
              ? (json['readAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['readAt']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'senderId': senderId,
      'receiverId': receiverId,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  bool get isUnread => status == NotificationStatus.unread;
} 