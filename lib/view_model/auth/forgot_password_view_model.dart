import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/auth_exception.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  ForgotPasswordViewModel({required this.userRepository});

  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailSent = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmailSent => _isEmailSent;

  void reset() {
    _errorMessage = null;
    _isEmailSent = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _isEmailSent = false;
    notifyListeners();
    try {
      await userRepository.resetPassword(email);
      _isLoading = false;
      _isEmailSent = true;
      notifyListeners();
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
    }
  }
}
