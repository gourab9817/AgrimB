import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../notification/notification_view_model.dart';
import '../../data/models/user_model.dart';

class VisitSiteRescheduleViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool success = false;
  String? errorMessage;
  String? claimedId;
  Map<String, dynamic>? _claimedData;
  final UserRepository userRepository;
  final NotificationViewModel? notificationViewModel;

  VisitSiteRescheduleViewModel({
    required this.userRepository,
    this.notificationViewModel,
  });

  void init(String claimedId) {
    this.claimedId = claimedId;
    _fetchClaimedData();
  }

  Future<void> _fetchClaimedData() async {
    if (claimedId == null) return;
    
    try {
      _claimedData = await userRepository.fetchVisitSiteData(claimedId!);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to fetch visit data: $e';
      notifyListeners();
    }
  }

  Future<void> rescheduleVisit({
    required DateTime newDateTime,
    required String newLocation,
  }) async {
    if (claimedId == null || _claimedData == null) return;
    
    final claimed = _claimedData!['claimed'] as Map<String, dynamic>?;
    final crop = _claimedData!['crop'] as Map<String, dynamic>?;
    
    if (claimed == null || crop == null) {
      errorMessage = 'Missing required data for rescheduling';
      return;
    }
    
    isLoading = true;
    errorMessage = null;
    success = false;
    notifyListeners();
    
    try {
      await userRepository.updateClaimedVisitStatusAndRescheduleCount(
        claimedId: claimedId!,
        visitStatus: 'Rescheduled and Pending',
        incrementReschedule: true,
        newVisitDateTime: newDateTime.toIso8601String(),
        newLocation: newLocation,
      );
      
      // Fetch buyer info for notification
      final UserModel? buyer = await userRepository.getCurrentUser();
      final String senderId = buyer?.uid ?? (claimed['buyerId'] ?? '');
      final String senderName = buyer?.name ?? 'Buyer';
      // Send notification to farmer
      if (notificationViewModel != null) {
        await notificationViewModel!.sendVisitRescheduledNotification(
          farmerId: claimed['farmerId'] ?? '',
          senderId: senderId,
          cropName: crop['name'] ?? '',
          newVisitDateTime: newDateTime,
          newLocation: newLocation,
          buyerName: senderName,
        );
      }
      
      success = true;
    } catch (e) {
      errorMessage = 'Failed to update visit: $e';
      success = false;
    }
    
    isLoading = false;
    notifyListeners();
  }
} 