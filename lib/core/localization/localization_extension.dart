import 'package:flutter/material.dart';
import 'app_localizations.dart';
 
extension LocalizationExtension on BuildContext {
  String l10n(String key) {
    return AppLocalizations.getString(key);
  }
} 