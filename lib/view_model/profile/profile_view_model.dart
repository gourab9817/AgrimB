// lib/view_model/profile/profile_view_model.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agrimb/data/models/user_model.dart';
import 'package:agrimb/data/repositories/user_repository.dart';
import 'dart:developer' as developer;

class ProfileViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  ProfileViewModel({required this.userRepository});

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggingOut = false;
  bool _isUploadingProfilePicture = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  Timer? _progressTimer;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
  bool get isUploadingProfilePicture => _isUploadingProfilePicture;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  // Fetch user data from the repository
  Future<void> fetchUserData() async {
    try {
      _setLoading(true);
      final userData = await userRepository.getCurrentUser();
      _user = userData;
      _errorMessage = null;
    } catch (e) {
      developer.log('Error fetching user data: $e');
      _errorMessage = 'Failed to load profile data. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // Handle user logout
  Future<bool> logout() async {
    try {
      _setLoggingOut(true);
      await userRepository.signOut();
      _errorMessage = null;
      return true;
    } catch (e) {
      developer.log('Error during logout: $e');
      _errorMessage = 'Failed to logout. Please try again.';
      return false;
    } finally {
      _setLoggingOut(false);
    }
  }

  // Upload profile picture with progress animation
  Future<bool> uploadProfilePicture(File imageFile) async {
    try {
      _setUploadingProfilePicture(true);
      _setUploadProgress(0.0);
      
      // Start progress animation
      _startProgressAnimation();
      
      final success = await userRepository.uploadProfilePicture(imageFile);
      
      if (success) {
        // Set progress to complete
        _setUploadProgress(1.0);
        _cancelProgressTimer();
        
        // Add small delay to show the completion
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Refresh user data to get the updated profile picture URL
        await fetchUserData();
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = 'Failed to upload profile picture. Please try again.';
        return false;
      }
    } catch (e) {
      developer.log('Error uploading profile picture: $e');
      _errorMessage = 'Failed to upload profile picture. Please try again.';
      return false;
    } finally {
      _cancelProgressTimer();
      _setUploadingProfilePicture(false);
      _setUploadProgress(0.0);
    }
  }

  // Animate the progress for better visual feedback
  void _startProgressAnimation() {
    // Cancel any existing timer
    _cancelProgressTimer();
    
    // Start with initial progress
    _setUploadProgress(0.05);
    
    // Create animation curve
    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      // Calculate next progress value using a sigmoid-like curve for natural acceleration/deceleration
      if (_uploadProgress < 0.9) {
        // Move faster in the middle, slower at the beginning and end
        double increment = 0.01;
        if (_uploadProgress > 0.1 && _uploadProgress < 0.7) {
          increment = 0.015; // Move faster in the middle range
        }
        
        // Add a bit of randomness for natural feel
        increment += (0.005 * (DateTime.now().millisecondsSinceEpoch % 3));
        
        _setUploadProgress(_uploadProgress + increment);
      }
    });
  }
  
  // Cancel the progress timer
  void _cancelProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  // Update user profile data
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? idNumber,
  }) async {
    try {
      _setLoading(true);
      
      if (_user != null) {
        final updatedUser = _user!.copyWith(
          name: name ?? _user!.name,
          phoneNumber: phoneNumber ?? _user!.phoneNumber,
          address: address ?? _user!.address,
          idNumber: idNumber ?? _user!.idNumber,
        );
        
        final success = await userRepository.updateUserProfile(updatedUser);
        
        if (success) {
          _user = updatedUser;
          _errorMessage = null;
          return true;
        } else {
          _errorMessage = 'Failed to update profile. Please try again.';
          return false;
        }
      }
      
      _errorMessage = 'No user data found. Please log in again.';
      return false;
    } catch (e) {
      developer.log('Error updating profile: $e');
      _errorMessage = 'Failed to update profile. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset error message
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to set logging out state
  void _setLoggingOut(bool loggingOut) {
    _isLoggingOut = loggingOut;
    notifyListeners();
  }
  
  // Helper method to set uploading profile picture state
  void _setUploadingProfilePicture(bool uploading) {
    _isUploadingProfilePicture = uploading;
    notifyListeners();
  }
  
  // Helper method to set upload progress
  void _setUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _cancelProgressTimer();
    super.dispose();
  }
}