import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../routes/app_routes.dart';
import '../../notification/notification_view_model.dart';
import '../../../data/models/user_model.dart';

class FinalDealViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final NotificationViewModel? notificationViewModel;
  
  FinalDealViewModel({
    required this.userRepository,
    this.notificationViewModel,
  });

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? dealData;

  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController finalDealPriceController = TextEditingController();

  DateTime? selectedDeliveryDate;

  bool isSubmitting = false;

  Future<void> fetchDealData(String claimedId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final claimedDoc = await FirebaseFirestore.instance.collection('claimedlist').doc(claimedId).get();
      if (!claimedDoc.exists) {
        errorMessage = 'Claimed record not found.';
        isLoading = false;
        notifyListeners();
        return;
      }
      final claimedData = claimedDoc.data()!;
      final farmerId = claimedData['farmerId'];
      final listingId = claimedData['listingId'];
      // Fetch farmer name
      final farmerDoc = await FirebaseFirestore.instance.collection('farmers').doc(farmerId).get();
      final farmerName = farmerDoc.exists ? (farmerDoc.data()?['name'] ?? '-') : '-';
      // Fetch crop name
      final cropDoc = await FirebaseFirestore.instance.collection('Listed crops').doc(listingId).get();
      final cropName = cropDoc.exists ? (cropDoc.data()?['name'] ?? '-') : '-';
      dealData = {
        'farmerName': farmerName,
        'cropName': cropName,
        'farmerId': farmerId,
        'listingId': listingId,
      };
    } catch (e) {
      errorMessage = 'Failed to fetch deal data.';
    }
    isLoading = false;
    notifyListeners();
  }

  void pickDeliveryDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      selectedDeliveryDate = picked;
      deliveryDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      notifyListeners();
    }
  }

  Future<void> submitFinalDeal(BuildContext context, String claimedId) async {
    if (dealData == null) return;
    final farmerName = dealData!['farmerName'] ?? '';
    final cropName = dealData!['cropName'] ?? '';
    final farmerId = dealData!['farmerId'] ?? '';
    final listingId = dealData!['listingId'] ?? '';
    final finalDealPriceStr = finalDealPriceController.text.trim();
    final farmerAadharNumberStr = aadhaarController.text.trim();
    final deliveryLocation = locationController.text.trim();
    final deliveryDate = deliveryDateController.text.trim();

    if (finalDealPriceStr.isEmpty || farmerAadharNumberStr.isEmpty || deliveryLocation.isEmpty || deliveryDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.red),
      );
      return;
    }
    int? finalDealPrice = int.tryParse(finalDealPriceStr);
    int? farmerAadharNumber = int.tryParse(farmerAadharNumberStr);
    if (finalDealPrice == null || farmerAadharNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Final deal price and Aadhaar number must be valid numbers.'), backgroundColor: Colors.red),
      );
      return;
    }
    isSubmitting = true;
    notifyListeners();
    try {
      await userRepository.updateFinalDealData(
        claimedId: claimedId,
        farmerName: farmerName,
        cropName: cropName,
        finalDealPrice: finalDealPrice,
        farmerAadharNumber: farmerAadharNumber,
        deliveryLocation: deliveryLocation,
        deliveryDate: deliveryDate,
      );
      
      // Fetch buyer info for notification
      final UserModel? buyer = await userRepository.getCurrentUser();
      final String senderId = buyer?.uid ?? '';
      final String senderName = buyer?.name ?? 'Buyer';
      // Send notification to farmer about deal completion
      if (notificationViewModel != null) {
        await notificationViewModel!.sendDealFinalizedNotification(
          farmerId: farmerId,
          senderId: senderId,
          cropName: cropName,
          finalPrice: finalDealPrice,
          buyerName: senderName,
        );
      }
      
      isSubmitting = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deal finalized successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.uploadVerificationDocs,
        arguments: claimedId,
      );
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to finalize deal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    aadhaarController.dispose();
    locationController.dispose();
    deliveryDateController.dispose();
    finalDealPriceController.dispose();
    super.dispose();
  }
} 