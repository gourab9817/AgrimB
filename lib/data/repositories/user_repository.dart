import 'dart:io';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

class UserRepository {
  final FirebaseService _firebaseService;
  final LocalStorageService _localStorageService;

  UserRepository(this._firebaseService, this._localStorageService);

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
    required String idNumber,
  }) async {
    final user = await _firebaseService.signUpWithEmail(
      email: email,
      password: password,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      idNumber: idNumber,
    );
    await _localStorageService.saveUserData(user);
    await NotificationService.updateFcmTokenForCurrentUser();
    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _firebaseService.signInWithEmail(
      email: email,
      password: password,
    );
    await _localStorageService.saveUserData(user);
    await NotificationService.updateFcmTokenForCurrentUser();
    return user;
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    await _localStorageService.clearUserData();
  }

  Future<void> resetPassword(String email) async {
    await _firebaseService.resetPassword(email);
  }

  Future<UserModel?> getCurrentUser() async {
    return await _localStorageService.getUserData();
  }

  Future<bool> reloadUser() async {
    return await _firebaseService.reloadUser();
  }

  Future<void> sendEmailVerification() async {
    await _firebaseService.sendEmailVerification();
  }

  Future<bool> updateUserProfile(UserModel user) async {
    final result = await _firebaseService.updateUserProfile(user);
    if (result) {
      await _localStorageService.saveUserData(user);
    }
    return result;
  }

  Future<bool> uploadProfilePicture(File imageFile) async {
    final url = await _firebaseService.uploadProfilePicture(imageFile);
    if (url != null) {
      final user = await getCurrentUser();
      if (user != null) {
        final updatedUser = user.copyWith(profilePictureUrl: url);
        await _localStorageService.saveUserData(updatedUser);
      }
      return true;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> fetchListedCrops() async {
    return await _firebaseService.fetchListedCrops();
  }

  Future<void> createClaimedListing({
    required String farmerId,
    required String buyerId,
    required DateTime claimedDateTime,
    required DateTime visitDateTime,
    required String listingId,
    required String location,
  }) async {
    await _firebaseService.createClaimedListing(
      farmerId: farmerId,
      buyerId: buyerId,
      claimedDateTime: claimedDateTime,
      visitDateTime: visitDateTime,
      listingId: listingId,
      location: location,
    );
  }

  Future<void> updateCropClaimedStatus({
    required String listingId,
    required bool claimed,
  }) async {
    await _firebaseService.updateCropClaimedStatus(
      listingId: listingId,
      claimed: claimed,
    );
  }

  Future<Map<String, dynamic>?> fetchFarmerDataById(String farmerId) async {
    return await _firebaseService.fetchFarmerDataById(farmerId);
  }

  Future<List<Map<String, dynamic>>> fetchClaimedCropsForBuyer(String buyerId) async {
    return await _firebaseService.fetchClaimedCropsForBuyer(buyerId);
  }

  Future<Map<String, dynamic>?> fetchVisitSiteData(String claimedId) async {
    return await _firebaseService.fetchVisitSiteData(claimedId);
  }

  Future<void> updateClaimedVisitStatusAndRescheduleCount({
    required String claimedId,
    String? visitStatus,
    bool incrementReschedule = false,
    String? newVisitDateTime,
    String? newLocation,
  }) async {
    await _firebaseService.updateClaimedVisitStatusAndRescheduleCount(
      claimedId: claimedId,
      visitStatus: visitStatus,
      incrementReschedule: incrementReschedule,
      newVisitDateTime: newVisitDateTime,
      newLocation: newLocation,
    );
  }

  Future<void> cancelVisitAndClaim(String claimedId) async {
    await _firebaseService.cancelVisitAndClaim(claimedId);
  }

  Future<void> updateFinalDealData({
    required String claimedId,
    required String farmerName,
    required String cropName,
    required int finalDealPrice,
    required int farmerAadharNumber,
    required String deliveryLocation,
    required String deliveryDate,
  }) async {
    await _firebaseService.updateFinalDealData(
      claimedId: claimedId,
      farmerName: farmerName,
      cropName: cropName,
      finalDealPrice: finalDealPrice,
      farmerAadharNumber: farmerAadharNumber,
      deliveryLocation: deliveryLocation,
      deliveryDate: deliveryDate,
    );
  }

  Future<String?> uploadClaimedDealDoc({
    required String claimedId,
    required File file,
    required String docType,
  }) async {
    return await _firebaseService.uploadClaimedDealDoc(
      claimedId: claimedId,
      file: file,
      docType: docType,
    );
  }

  Future<void> updateClaimedListWithDocs({
    required String claimedId,
    required String? signedContractUrl,
    required String? selfieWithFarmerUrl,
    required String? finalProductPhotoUrl,
  }) async {
    await _firebaseService.updateClaimedListWithDocs(
      claimedId: claimedId,
      signedContractUrl: signedContractUrl,
      selfieWithFarmerUrl: selfieWithFarmerUrl,
      finalProductPhotoUrl: finalProductPhotoUrl,
    );
  }

  Future<UserModel?> fetchAndUpdateUserFromServer(String uid) async {
    final user = await _firebaseService.fetchUserByUid(uid);
    if (user != null) {
      await _localStorageService.saveUserData(user);
    }
    return user;
  }
}
