import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';

class ProfileVerificationViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  bool _isChecking = false;
  UserModel? _user;

  bool get isChecking => _isChecking;
  UserModel? get user => _user;

  ProfileVerificationViewModel({required this.userRepository});

  Future<void> loadUser() async {
    _user = await userRepository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> checkVerification() async {
    _isChecking = true;
    notifyListeners();
    try {
      final localUser = await userRepository.getCurrentUser();
      if (localUser == null) {
        _isChecking = false;
        notifyListeners();
        return false;
      }
      final updatedUser = await userRepository.fetchAndUpdateUserFromServer(localUser.uid);
      _user = updatedUser;
      _isChecking = false;
      notifyListeners();
      return updatedUser?.profileVerified ?? false;
    } catch (e) {
      _isChecking = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await checkVerification();
  }
} 