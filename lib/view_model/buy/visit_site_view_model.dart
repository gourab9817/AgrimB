import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../notification/notification_view_model.dart';
import '../../data/models/user_model.dart';

class VisitSiteViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final NotificationViewModel? notificationViewModel;
  bool isLoading = false;
  Map<String, dynamic>? visitSiteData;
  String? errorMessage;
  bool isCancelLoading = false;
  String? cancelError;

  VisitSiteViewModel({required this.userRepository, this.notificationViewModel});

  Future<void> fetchVisitSiteData(String claimedId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      visitSiteData = await userRepository.fetchVisitSiteData(claimedId);
      if (visitSiteData == null) {
        errorMessage = 'No data found for this visit.';
      }
    } catch (e) {
      errorMessage = 'Failed to fetch visit data.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> cancelVisit(String claimedId) async {
    isCancelLoading = true;
    cancelError = null;
    notifyListeners();
    try {
      await userRepository.cancelVisitAndClaim(claimedId);
      // Fetch visit and crop data for notification
      final data = await userRepository.fetchVisitSiteData(claimedId);
      final claimed = data?['claimed'] as Map<String, dynamic>?;
      final crop = data?['crop'] as Map<String, dynamic>?;
      // Fetch buyer info for notification
      final UserModel? buyer = await userRepository.getCurrentUser();
      final String senderId = buyer?.uid ?? (claimed?['buyerId'] ?? '');
      final String senderName = buyer?.name ?? 'Buyer';
      final String farmerId = claimed?['farmerId'] ?? '';
      final String cropName = crop?['name'] ?? '';
      if (notificationViewModel != null && farmerId.isNotEmpty) {
        await notificationViewModel!.sendVisitCancelledNotification(
          farmerId: farmerId,
          senderId: senderId,
          cropName: cropName,
          buyerName: senderName,
        );
      }
      isCancelLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      cancelError = 'Failed to cancel visit: $e';
      isCancelLoading = false;
      notifyListeners();
      return false;
    }
  }
} 