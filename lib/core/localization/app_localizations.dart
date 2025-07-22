import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  static const Locale _defaultLocale = Locale('en');
  static Locale _currentLocale = _defaultLocale;
  
  static Map<String, dynamic> _localizedStrings = {};
  
  static Locale get currentLocale => _currentLocale;
  
  static void setLocale(Locale locale) {
    _currentLocale = locale;
  }
  
  static Future<void> loadLanguage() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/translations/${_currentLocale.languageCode}.json',
      );
      _localizedStrings = json.decode(jsonString);
    } catch (e) {
      // Fallback to English if the language file is not found
      String jsonString = await rootBundle.loadString(
        'assets/translations/en.json',
      );
      _localizedStrings = json.decode(jsonString);
    }
  }
  
  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
  
  static String getString(String key) {
    return translate(key);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations.setLocale(locale);
    await AppLocalizations.loadLanguage();
    return AppLocalizations();
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 