import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/claimed_listing_model.dart';
import '../notification/notification_view_model.dart';
import '../../data/models/user_model.dart';

class VisitScheduleViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final NotificationViewModel? notificationViewModel;
  
  bool isLoading = false;
  String? errorMessage;
  bool success = false;
  Map<String, dynamic>? _farmerData;
  Map<String, dynamic>? get farmerData => _farmerData;

  bool _disposed = false;

  VisitScheduleViewModel({
    required this.userRepository,
    this.notificationViewModel,
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  Future<void> scheduleVisit({
    required String farmerId,
    required String buyerId,
    required DateTime claimedDateTime,
    required DateTime visitDateTime,
    required String listingId,
    required String location,
    required String cropName,
    required String buyerName,
  }) async {
    isLoading = true;
    errorMessage = null;
    success = false;
    notifyListeners();
    
    try {
      // Create claimed listing
      await userRepository.createClaimedListing(
        farmerId: farmerId,
        buyerId: buyerId,
        claimedDateTime: claimedDateTime,
        visitDateTime: visitDateTime,
        listingId: listingId,
        location: location,
      );
      
      // Update crop claimed status
      await userRepository.updateCropClaimedStatus(
        listingId: listingId,
        claimed: true,
      );
      
      // Fetch farmer data
      _farmerData = await userRepository.fetchFarmerDataById(farmerId);
      
      // Fetch buyer info for notification
      final UserModel? buyer = await userRepository.getCurrentUser();
      final String senderId = buyer?.uid ?? buyerId;
      final String senderName = buyer?.name ?? buyerName;
      // Send notification to farmer
      if (notificationViewModel != null) {
        await notificationViewModel!.sendVisitScheduledNotification(
          farmerId: farmerId,
          senderId: senderId,
          cropName: cropName,
          visitDateTime: visitDateTime,
          location: location,
          buyerName: senderName,
        );
      }
      
      success = true;
    } catch (e, st) {
      errorMessage = e.toString().contains('already been claimed')
        ? 'This listing has already been claimed by another user.'
        : 'Failed to claim listing: ${e.toString()}';
      print('Claim error: $e\n$st');
      success = false;
    }
    
    isLoading = false;
    safeNotifyListeners();
  }
}
