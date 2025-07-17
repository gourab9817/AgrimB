import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/auth_exception.dart';
import 'dart:io';
// Add your Firebase imports here
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  bool get isUserLoggedIn => currentUser != null;
  bool get isEmailVerified => currentUser?.emailVerified ?? false;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> reloadUser() async {
    try {
      if (_auth.currentUser == null) return false;
      await _auth.currentUser!.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e, st) {
      developer.log('FirebaseService: Error in reloadUser: $e', error: e, stackTrace: st);
      throw AuthException(code: 'reload-failed', message: 'Failed to reload user data: $e');
    }
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
    required String idNumber,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        throw AuthException(code: 'null-user', message: 'User creation failed');
      }
      final user = UserModel(
        uid: firebaseUser.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        idNumber: idNumber,
        isEmailVerified: firebaseUser.emailVerified,
        profileVerified: false,
      );
      await _firestore.collection('buyers').doc(user.uid).set(user.toJson());
      // FCM token is updated after signup by NotificationService
      return user;
    } on FirebaseAuthException catch (e, st) {
      developer.log('FirebaseService: Auth error during signup: [32m${e.code}[0m', error: e, stackTrace: st);
      throw _handleFirebaseAuthException(e);
    } catch (e, st) {
      developer.log('FirebaseService: Unknown error during signup: $e', error: e, stackTrace: st);
      throw AuthException(code: 'unknown', message: e.toString());
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        throw AuthException(code: 'null-user', message: 'Sign-in failed');
      }
      final docRef = _firestore.collection('buyers').doc(firebaseUser.uid);
      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        data['isEmailVerified'] = firebaseUser.emailVerified;
        if (!data.containsKey('profile_verified')) {
          data['profile_verified'] = false;
        }
        return UserModel.fromJson(data);
      } else {
        final minimal = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          isEmailVerified: firebaseUser.emailVerified,
          profileVerified: false,
        );
        await docRef.set(minimal.toJson(), SetOptions(merge: true));
        // FCM token is updated after login by NotificationService
        return minimal;
      }
    } on FirebaseAuthException catch (e, st) {
      developer.log('FirebaseService: Auth error during signin: [32m${e.code}[0m', error: e, stackTrace: st);
      throw _handleFirebaseAuthException(e);
    } catch (e, st) {
      developer.log('FirebaseService: Unknown error during signin: $e', error: e, stackTrace: st);
      throw AuthException(code: 'unknown', message: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e, st) {
      developer.log('FirebaseService: Error during signout: ${e.code}', error: e, stackTrace: st);
      throw _handleFirebaseAuthException(e);
    } catch (e, st) {
      developer.log('FirebaseService: Unknown error during signout: $e', error: e, stackTrace: st);
      throw AuthException(code: 'unknown', message: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, st) {
      developer.log('FirebaseService: Error sending reset: ${e.code}', error: e, stackTrace: st);
      throw _handleFirebaseAuthException(e);
    } catch (e, st) {
      developer.log('FirebaseService: Unknown error sending reset: $e', error: e, stackTrace: st);
      throw AuthException(code: 'unknown', message: e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  Future<bool> updateUserProfile(UserModel user) async {
    try {
      if (_auth.currentUser == null || _auth.currentUser!.uid != user.uid) {
        throw AuthException(code: 'user-mismatch', message: 'Cannot update another user\'s profile');
      }
      await _firestore.collection('buyers').doc(user.uid).update(user.toJson());
      return true;
    } catch (e, st) {
      developer.log('FirebaseService: Error updating user profile: $e', error: e, stackTrace: st);
      return false;
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      if (_auth.currentUser == null) {
        throw AuthException(code: 'user-not-logged-in', message: 'User not logged in');
      }
      final userId = _auth.currentUser!.uid;
      final storageRef = _storage.ref().child('buyersprofilepicture').child(userId);
      final uploadTask = storageRef.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        await _firestore.collection('buyers').doc(userId).update({'profilePictureUrl': downloadUrl});
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e, st) {
      developer.log('FirebaseService: Error uploading profile picture: $e', error: e, stackTrace: st);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchListedCrops() async {
    try {
      final querySnapshot = await _firestore.collection('Listed crops').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e, st) {
      developer.log('FirebaseService: Error fetching listed crops: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> createClaimedListing({
    required String farmerId,
    required String buyerId,
    required DateTime claimedDateTime,
    required DateTime visitDateTime,
    required String listingId,
    required String location,
  }) async {
    final listingRef = _firestore.collection('Listed crops').doc(listingId);
    final claimedListRef = _firestore.collection('claimedlist').doc();
    try {
      await _firestore.runTransaction((transaction) async {
        final listingSnap = await transaction.get(listingRef);
        if (!listingSnap.exists) {
          throw Exception('Listing does not exist.');
        }
        if (listingSnap.data()?['claimed'] == true) {
          throw Exception('This listing has already been claimed.');
        }
        transaction.update(listingRef, {'claimed': true});
        transaction.set(claimedListRef, {
          'id': claimedListRef.id,
          'farmerId': farmerId,
          'buyerId': buyerId,
          'claimedDateTime': claimedDateTime.toIso8601String(),
          'visitDateTime': visitDateTime.toIso8601String(),
          'listingId': listingId,
          'location': location,
          'VisitStatus': 'Pending',
          'rescheduleCount': 0,
        });
      });
    } catch (e, st) {
      developer.log('FirebaseService: Error creating claimed listing: $e', error: e, stackTrace: st);
      throw Exception(e.toString());
    }
  }

  Future<void> updateClaimedVisitStatusAndRescheduleCount({
    required String claimedId,
    String? visitStatus,
    bool incrementReschedule = false,
    String? newVisitDateTime,
    String? newLocation,
  }) async {
    final updateData = <String, dynamic>{};
    if (visitStatus != null) updateData['VisitStatus'] = visitStatus;
    if (incrementReschedule) {
      final doc = await _firestore.collection('claimedlist').doc(claimedId).get();
      final currentCount = (doc.data()?['rescheduleCount'] ?? 0) as int;
      updateData['rescheduleCount'] = currentCount + 1;
    }
    if (newVisitDateTime != null) updateData['visitDateTime'] = newVisitDateTime;
    if (newLocation != null) updateData['location'] = newLocation;
    await _firestore.collection('claimedlist').doc(claimedId).update(updateData);
  }

  Future<void> updateCropClaimedStatus({
    required String listingId,
    required bool claimed,
  }) async {
    try {
      await _firestore.collection('Listed crops').doc(listingId).update({'claimed': claimed});
    } catch (e, st) {
      developer.log('FirebaseService: Error updating crop claimed status: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchFarmerDataById(String farmerId) async {
    try {
      final doc = await _firestore.collection('farmers').doc(farmerId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e, st) {
      developer.log('FirebaseService: Error fetching farmer data: $e', error: e, stackTrace: st);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchClaimedCropsForBuyer(String buyerId) async {
    try {
      final querySnapshot = await _firestore.collection('claimedlist').where('buyerId', isEqualTo: buyerId).get();
      final claimedListings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      // Fetch the actual crop details for each claimed listing
      List<Map<String, dynamic>> crops = [];
      for (var claimed in claimedListings) {
        final listingId = claimed['listingId'];
        final cropDoc = await _firestore.collection('Listed crops').doc(listingId).get();
        if (cropDoc.exists) {
          final cropData = cropDoc.data()!;
          cropData['id'] = cropDoc.id;
          cropData['claimed'] = true;
          cropData['claimedId'] = claimed['id'];
          cropData['VisitStatus'] = claimed['VisitStatus'] ?? 'Pending';
          crops.add(cropData);
        }
      }
      return crops;
    } catch (e, st) {
      developer.log('FirebaseService: Error fetching claimed crops: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchVisitSiteData(String claimedId) async {
    try {
      final claimedDoc = await _firestore.collection('claimedlist').doc(claimedId).get();
      if (!claimedDoc.exists) return null;
      final claimedData = claimedDoc.data()!;
      // Fetch crop details
      final listingId = claimedData['listingId'];
      final cropDoc = await _firestore.collection('Listed crops').doc(listingId).get();
      final cropData = cropDoc.exists ? cropDoc.data()! : {};
      // Fetch farmer details
      final farmerId = claimedData['farmerId'];
      final farmerDoc = await _firestore.collection('farmers').doc(farmerId).get();
      final farmerData = farmerDoc.exists ? farmerDoc.data()! : {};
      return {
        'claimed': claimedData,
        'crop': cropData,
        'farmer': farmerData,
      };
    } catch (e, st) {
      developer.log('FirebaseService: Error fetching visit site data: $e', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> cancelVisitAndClaim(String claimedId) async {
    // 1. Update VisitStatus to 'Cancelled' in claimedlist
    final claimedDoc = await _firestore.collection('claimedlist').doc(claimedId).get();
    if (!claimedDoc.exists) throw Exception('Claimed document not found');
    final listingId = claimedDoc.data()?['listingId'];
    await _firestore.collection('claimedlist').doc(claimedId).update({'VisitStatus': 'Cancelled'});
    // 2. Update claimed to false in Listed crops
    if (listingId != null) {
      await _firestore.collection('Listed crops').doc(listingId).update({'claimed': false});
    }
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
    await _firestore.collection('claimedlist').doc(claimedId).update({
      'farmer_name': farmerName,
      'crop_name': cropName,
      'final_deal_price': finalDealPrice,
      'farmer_aadhar_number': farmerAadharNumber,
      'delivery_location': deliveryLocation,
      'delivery_date': deliveryDate,
    });
  }

  Future<String?> uploadClaimedDealDoc({
    required String claimedId,
    required File file,
    required String docType,
  }) async {
    try {
      final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('claimeddealdocs').child(claimedId).child(fileName);
      final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e, st) {
      developer.log('FirebaseService: Error uploading claimed deal doc: $e', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> updateClaimedListWithDocs({
    required String claimedId,
    required String? signedContractUrl,
    required String? selfieWithFarmerUrl,
    required String? finalProductPhotoUrl,
  }) async {
    final updateData = <String, dynamic>{
      'VisitStatus': 'Completed',
    };
    if (signedContractUrl != null) updateData['signed_contract'] = signedContractUrl;
    if (selfieWithFarmerUrl != null) updateData['selfie_with_farmer'] = selfieWithFarmerUrl;
    if (finalProductPhotoUrl != null) updateData['final_product_photo'] = finalProductPhotoUrl;
    await _firestore.collection('claimedlist').doc(claimedId).update(updateData);
  }

  Future<UserModel?> fetchUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection('buyers').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e, st) {
      developer.log('FirebaseService: Error fetching user by uid: $e', error: e, stackTrace: st);
      return null;
    }
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(code: e.code, message: 'No user found with this email.');
      case 'wrong-password':
        return AuthException(code: e.code, message: 'Incorrect password.');
      case 'invalid-email':
        return AuthException(code: e.code, message: 'Invalid email address.');
      case 'user-disabled':
        return AuthException(code: e.code, message: 'This user is disabled.');
      case 'email-already-in-use':
        return AuthException(code: e.code, message: 'Email already in use.');
      case 'operation-not-allowed':
        return AuthException(code: e.code, message: 'Operation not allowed.');
      case 'weak-password':
        return AuthException(code: e.code, message: 'Password is too weak.');
      case 'too-many-requests':
        return AuthException(code: e.code, message: 'Too many attempts; try again later.');
      default:
        return AuthException(code: e.code, message: e.message ?? 'Unknown auth error');
    }
  }
}
