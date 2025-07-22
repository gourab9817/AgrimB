import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/local_storage_service.dart';
import '../../routes/app_routes.dart';

class LanguageSelectionViewModel extends ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isLoading = false;
  String? _selectedLanguage;

  bool get isLoading => _isLoading;
  String? get selectedLanguage => _selectedLanguage;

  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  Future<void> selectLanguage(BuildContext context, String languageCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Set the language
      AppLocalizations.setLocale(Locale(languageCode));
      await AppLocalizations.loadLanguage();
      
      // Save language preference
      await _localStorageService.setLanguage(languageCode);
      
      _isLoading = false;
      notifyListeners();

      // Navigate to appropriate screen based on user authentication
      if (context.mounted) {
        final user = await _localStorageService.getUserData();
        if (user != null) {
          if (user.profileVerified) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profileVerification);
          }
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error selecting language: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.getString('error')),
          ),
        );
      }
    }
  }

  Future<void> loadSavedLanguage() async {
    try {
      final savedLanguage = await _localStorageService.getLanguage();
      if (savedLanguage != 'english') {
        _selectedLanguage = savedLanguage;
        AppLocalizations.setLocale(Locale(savedLanguage));
        await AppLocalizations.loadLanguage();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }
} 