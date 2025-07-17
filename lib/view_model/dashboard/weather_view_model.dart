// lib/view_model/dashboard/weather_view_model.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/weather_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/local_storage_service2.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  late LocalStorageService2 _localStorage;

  // State variables
  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  bool _isLoading = false;
  String? _error;
  bool _useCelsius = true;
  LocationModel? _currentLocation;
  DateTime? _lastUpdated;

  WeatherViewModel() {
    _initializeLocalStorage();
  }

  Future<void> _initializeLocalStorage() async {
    _localStorage = await LocalStorageService2.getInstance();
  }

  // // State variables
  // WeatherModel? _currentWeather;
  // List<ForecastModel> _forecast = [];
  // bool _isLoading = false;
  // String? _error;
  // bool _useCelsius = true;
  // LocationModel? _currentLocation;
  // DateTime? _lastUpdated;

  // // State variables
  // WeatherModel? _currentWeather;
  // List<ForecastModel> _forecast = [];
  // bool _isLoading = false;
  // String? _error;
  // bool _useCelsius = true;
  // LocationModel? _currentLocation;
  // DateTime? _lastUpdated;

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useCelsius => _useCelsius;
  LocationModel? get currentLocation => _currentLocation;
  DateTime? get lastUpdated => _lastUpdated;

  // Check if data needs refresh (older than 30 minutes)
  bool get needsRefresh {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > 30;
  }

  // Initialize weather data
  Future<void> initializeWeather() async {
    // Load cached data first
    await _loadCachedData();
    
    // Then fetch fresh data
    if (needsRefresh) {
      await fetchWeatherData();
    }
  }

  // Fetch weather data
  Future<void> fetchWeatherData() async {
    try {
      _setLoading(true);
      _error = null;

      // Get current location
      _currentLocation = await _locationService.getCurrentLocation();

      // Fetch current weather and forecast in parallel
      final results = await Future.wait([
        _weatherService.getCurrentWeather(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
        ),
        _weatherService.getWeatherForecast(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
        ),
      ]);

      _currentWeather = results[0] as WeatherModel;
      _forecast = results[1] as List<ForecastModel>;
      _lastUpdated = DateTime.now();

      // Cache the data
      await _cacheWeatherData();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Refresh weather data
  Future<void> refreshWeather() async {
    await fetchWeatherData();
  }

  // Toggle temperature unit
  void toggleTemperatureUnit() {
    _useCelsius = !_useCelsius;
    _localStorage.setBool('use_celsius', _useCelsius);
    notifyListeners();
  }

  // Get weather by city
  Future<void> getWeatherByCity(String cityName) async {
    try {
      _setLoading(true);
      _error = null;

      _currentWeather = await _weatherService.getWeatherByCity(cityName);
      
      // Update forecast for the city's location
      if (_currentWeather != null) {
        // Extract coordinates from the weather data
        // Note: You might need to modify WeatherModel to include coordinates
        // For now, we'll just clear the forecast
        _forecast = [];
      }

      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    return await _locationService.requestLocationPermission();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  // Private methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Cache weather data
  Future<void> _cacheWeatherData() async {
    if (_currentWeather != null) {
      final weatherData = {
        'current': _currentWeatherToJson(_currentWeather!),
        'forecast': _forecast.map(_forecastToJson).toList(),
        'lastUpdated': _lastUpdated?.toIso8601String(),
        'location': {
          'latitude': _currentLocation?.latitude,
          'longitude': _currentLocation?.longitude,
          'cityName': _currentLocation?.cityName,
          'stateName': _currentLocation?.stateName,
        },
      };
      
      // Using simple key-value storage for weather data
      // If your LocalStorageService has different methods, adjust accordingly
      await Future.wait([
        _localStorage.setString('weather_data', json.encode(weatherData)),
      ]);
    }
  }

  // Load cached data
  Future<void> _loadCachedData() async {
    try {
      final cachedJson = await _localStorage.getString('weather_data');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final data = json.decode(cachedJson);
        
        // Parse cached data
        if (data['current'] != null) {
          _currentWeather = _weatherFromJson(data['current']);
        }
        
        if (data['forecast'] != null) {
          _forecast = (data['forecast'] as List)
              .map((e) => _forecastFromJson(e))
              .toList();
        }
        
        if (data['lastUpdated'] != null) {
          _lastUpdated = DateTime.parse(data['lastUpdated']);
        }
        
        if (data['location'] != null) {
          final loc = data['location'];
          _currentLocation = LocationModel(
            latitude: loc['latitude'] ?? 0.0,
            longitude: loc['longitude'] ?? 0.0,
            cityName: loc['cityName'],
            stateName: loc['stateName'],
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached weather data: $e');
    }
    
    // Load temperature unit preference
    _useCelsius = await _localStorage.getBool('use_celsius') ?? true;
  }

  // Helper methods for JSON conversion
  Map<String, dynamic> _currentWeatherToJson(WeatherModel weather) {
    return {
      'cityName': weather.cityName,
      'stateName': weather.stateName,
      'temperature': weather.temperature,
      'tempMin': weather.tempMin,
      'tempMax': weather.tempMax,
      'feelsLike': weather.feelsLike,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'pressure': weather.pressure,
      'weatherMain': weather.weatherMain,
      'weatherDescription': weather.weatherDescription,
      'weatherIcon': weather.weatherIcon,
      'precipitation': weather.precipitation,
      'visibility': weather.visibility,
    };
  }

  WeatherModel _weatherFromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'],
      stateName: json['stateName'],
      temperature: json['temperature'],
      tempMin: json['tempMin'],
      tempMax: json['tempMax'],
      feelsLike: json['feelsLike'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'],
      pressure: json['pressure'],
      weatherMain: json['weatherMain'],
      weatherDescription: json['weatherDescription'],
      weatherIcon: json['weatherIcon'],
      timestamp: DateTime.now(),
      precipitation: json['precipitation'],
      visibility: json['visibility'],
    );
  }

  Map<String, dynamic> _forecastToJson(ForecastModel forecast) {
    return {
      'date': forecast.date.toIso8601String(),
      'tempMin': forecast.tempMin,
      'tempMax': forecast.tempMax,
      'weatherMain': forecast.weatherMain,
      'weatherDescription': forecast.weatherDescription,
      'weatherIcon': forecast.weatherIcon,
      'humidity': forecast.humidity,
      'precipitation': forecast.precipitation,
    };
  }

  ForecastModel _forecastFromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: DateTime.parse(json['date']),
      tempMin: json['tempMin'],
      tempMax: json['tempMax'],
      weatherMain: json['weatherMain'],
      weatherDescription: json['weatherDescription'],
      weatherIcon: json['weatherIcon'],
      humidity: json['humidity'],
      precipitation: json['precipitation'],
    );
  }
}