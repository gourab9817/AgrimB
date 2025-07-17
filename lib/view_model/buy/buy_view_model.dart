import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';

class BuyViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  List<Map<String, dynamic>> listings = [];
  List<Map<String, dynamic>> filteredListings = [];
  bool isLoading = false;
  int selectedTab = 0;
  String searchQuery = '';
  String selectedType = '';
  String selectedLocation = '';
  List<Map<String, dynamic>> claimedCrops = [];
  String? buyerId;

  BuyViewModel({required this.userRepository});

  Future<void> fetchAllCrops(String buyerId) async {
    isLoading = true;
    notifyListeners();
    try {
      // Fetch all unclaimed crops
      listings = await userRepository.fetchListedCrops();
      // Fetch claimed crops for this user
      claimedCrops = await userRepository.fetchClaimedCropsForBuyer(buyerId);
      applyFilters();
    } catch (e) {
      listings = [];
      filteredListings = [];
      claimedCrops = [];
    }
    isLoading = false;
    notifyListeners();
  }

  void setTab(int tab) {
    selectedTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query.toLowerCase();
    applyFilters();
  }

  void setTypeFilter(String type) {
    selectedType = type;
    applyFilters();
  }

  void setLocationFilter(String location) {
    selectedLocation = location;
    applyFilters();
  }

  void clearFilters() {
    searchQuery = '';
    selectedType = '';
    selectedLocation = '';
    applyFilters();
  }

  void applyFilters() {
    filteredListings = listings.where((listing) {
      final name = (listing['name'] ?? '').toString().toLowerCase();
      final type = (listing['type'] ?? '').toString().toLowerCase();
      final location = (listing['location'] ?? '').toString().toLowerCase();

      bool matchesSearch = searchQuery.isEmpty || 
          name.contains(searchQuery) ||
          type.contains(searchQuery) ||
          location.contains(searchQuery);

      bool matchesType = selectedType.isEmpty || type == selectedType.toLowerCase();
      bool matchesLocation = selectedLocation.isEmpty || location == selectedLocation.toLowerCase();

      return matchesSearch && matchesType && matchesLocation;
    }).toList();
    
    notifyListeners();
  }

  List<String> get uniqueTypes {
    return listings
        .map((listing) => (listing['type'] ?? '').toString())
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> get uniqueLocations {
    return listings
        .map((listing) => (listing['location'] ?? '').toString())
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> get visitPendingCrops => claimedCrops.where((crop) => (crop['VisitStatus'] ?? 'Pending') != 'Cancelled' && (crop['VisitStatus'] ?? 'Pending') != 'Completed').toList();
  List<Map<String, dynamic>> get visitCancelledCrops => claimedCrops.where((crop) => (crop['VisitStatus'] ?? 'Pending') == 'Cancelled').toList();
  List<Map<String, dynamic>> get visitCompletedCrops => claimedCrops.where((crop) => (crop['VisitStatus'] ?? '') == 'Completed').toList();
} 