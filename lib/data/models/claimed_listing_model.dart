class ClaimedListingModel {
  final String id;
  final String farmerId;
  final String buyerId;
  final DateTime claimedDateTime;
  final String listingId;
  final String visitStatus;
  final int rescheduleCount;

  ClaimedListingModel({
    required this.id,
    required this.farmerId,
    required this.buyerId,
    required this.claimedDateTime,
    required this.listingId,
    required this.visitStatus,
    required this.rescheduleCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'buyerId': buyerId,
      'claimedDateTime': claimedDateTime.toIso8601String(),
      'listingId': listingId,
      'VisitStatus': visitStatus,
      'rescheduleCount': rescheduleCount,
    };
  }

  factory ClaimedListingModel.fromJson(Map<String, dynamic> json) {
    return ClaimedListingModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      claimedDateTime: DateTime.parse(json['claimedDateTime']),
      listingId: json['listingId'] ?? '',
      visitStatus: json['VisitStatus'] ?? 'Pending',
      rescheduleCount: json['rescheduleCount'] ?? 0,
    );
  }
} 