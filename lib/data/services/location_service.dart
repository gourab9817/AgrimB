// lib/data/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/weather_model.dart';

class LocationService {
  static const String _locationPermissionDenied = 'Location permission denied';
  static const String _locationServicesDisabled = 'Location services are disabled';
  static const String _locationPermissionDeniedForever = 'Location permissions are permanently denied';

  Future<LocationModel> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(_locationServicesDisabled);
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(_locationPermissionDenied);
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately
        throw Exception(_locationPermissionDeniedForever);
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get location details from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? cityName;
      String? stateName;
      String? countryCode;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        cityName = place.locality ?? place.subAdministrativeArea ?? '';
        stateName = place.administrativeArea ?? '';
        countryCode = place.isoCountryCode ?? '';
      }

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
        stateName: stateName,
        countryCode: countryCode,
      );
    } catch (e) {
      // If getting exact location fails, return a default location
      // You can change this to your preferred default location
      return LocationModel(
        latitude: 16.5155,  // Vijayawada coordinates as fallback
        longitude: 80.6326,
        cityName: 'Vijayawada',
        stateName: 'Andhra Pradesh',
        countryCode: 'IN',
      );
    }
  }

  // Get location name from coordinates
  Future<Map<String, String>> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'city': place.locality ?? place.subAdministrativeArea ?? '',
          'state': place.administrativeArea ?? '',
          'country': place.country ?? '',
        };
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
    
    return {
      'city': '',
      'state': '',
      'country': '',
    };
  }

  // Open app settings if permission is denied forever
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
}