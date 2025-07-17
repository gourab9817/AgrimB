import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../view/screens/dashboard/buy_card.dart';
import '../../view/screens/dashboard/weather_data.dart';

class DashboardViewModel extends ChangeNotifier {
  String _username = 'Jonny';
  String get username => _username;

  String _currentDate = '';
  String get currentDate => _currentDate;

  List<String> get buyCropImages => List.unmodifiable(buyCropImages);
  List<Map<String, String>> get bestDealsList => List.unmodifiable(bestDealsList);
  List<Map<String, String>> get weatherDataList => List.unmodifiable(weatherDataList);

  // Dummy mandi data
  List<Map<String, String>> _mandiData = [
    {'name': 'Mustard', 'price': '₹71,000/MT', 'change': '+₹12,496 since last month'},
    {'name': 'Wheat', 'price': '₹28,500/MT', 'change': '+₹638 since last month'},
  ];
  List<Map<String, String>> get mandiData => List.unmodifiable(_mandiData);

  Timer? _timer;

  DashboardViewModel() {
    _updateDate();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateDate());
  }

  void _updateDate() {
    final now = DateTime.now();
    _currentDate = DateFormat('EEEE, dd MMM yyyy').format(now);
    notifyListeners();
  }

  // Stub for language change
  String _language = 'en';
  String get language => _language;
  void changeLanguage(String langCode) {
    _language = langCode;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
