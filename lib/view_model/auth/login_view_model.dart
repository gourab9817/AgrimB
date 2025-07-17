import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/auth_exception.dart';
import '../../data/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  LoginViewModel({required this.userRepository});

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await userRepository.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return user;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return null;
    }
  }
}
