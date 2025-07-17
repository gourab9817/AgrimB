// lib/data/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'location_service.dart';

class WeatherService {
  // Replace with your actual OpenWeatherMap API key
  static const String _apiKey = '027e7a908659ff151f4e9a18b0a7a78a';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  final LocationService _locationService = LocationService();

  // Get current weather
  Future<WeatherModel> getCurrentWeather({
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Get location if not provided
      if (latitude == null || longitude == null) {
        final location = await _locationService.getCurrentLocation();
        latitude = location.latitude;
        longitude = location.longitude;
      }

      // Make API call
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var weather = WeatherModel.fromJson(data);
        
        // Get location name details
        final locationDetails = await _locationService.getLocationName(
          latitude,
          longitude,
        );
        
        // Update weather with state name
        weather = weather.copyWith(stateName: locationDetails['state']);
        
        return weather;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get weather forecast (next 4 days)
  Future<List<ForecastModel>> getWeatherForecast({
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Get location if not provided
      if (latitude == null || longitude == null) {
        final location = await _locationService.getCurrentLocation();
        latitude = location.latitude;
        longitude = location.longitude;
      }

      // Make API call for daily forecast
      final url = Uri.parse(
        '$_baseUrl/forecast/daily?lat=$latitude&lon=$longitude&cnt=5&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        // Skip the first item (today) and take next 4 days
        return forecastList
            .skip(1)
            .take(4)
            .map((json) => ForecastModel.fromJson(json))
            .toList();
      } else {
        // If daily forecast fails, try hourly forecast and process it
        return await _getHourlyForecastProcessed(latitude, longitude);
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  // Process hourly forecast to get daily data
  Future<List<ForecastModel>> _getHourlyForecastProcessed(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hourlyList = data['list'];
        
        // Group by day and process
        Map<String, List<dynamic>> dailyData = {};
        
        for (var hourData in hourlyList) {
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(hourData['dt'] * 1000);
          String dateKey = '${dt.year}-${dt.month}-${dt.day}';
          
          if (!dailyData.containsKey(dateKey)) {
            dailyData[dateKey] = [];
          }
          dailyData[dateKey]!.add(hourData);
        }
        
        List<ForecastModel> forecasts = [];
        int count = 0;
        
        // Skip today and process next 4 days
        dailyData.keys.skip(1).forEach((dateKey) {
          if (count >= 4) return;
          
          var dayData = dailyData[dateKey]!;
          if (dayData.isEmpty) return;
          
          // Calculate min/max temps
          double minTemp = double.infinity;
          double maxTemp = double.negativeInfinity;
          Map<String, int> weatherCounts = {};
          int totalHumidity = 0;
          double totalRain = 0;
          
          for (var hour in dayData) {
            double temp = (hour['main']['temp'] as num).toDouble();
            minTemp = temp < minTemp ? temp : minTemp;
            maxTemp = temp > maxTemp ? temp : maxTemp;
            
            String weatherMain = hour['weather'][0]['main'];
            weatherCounts[weatherMain] = (weatherCounts[weatherMain] ?? 0) + 1;
            
            totalHumidity += hour['main']['humidity'] as int;
            totalRain += (hour['rain']?['3h'] ?? 0).toDouble();
          }
          
          // Get most frequent weather condition
          String dominantWeather = weatherCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
          
          // Use the middle of the day for weather description
          var midDayData = dayData[dayData.length ~/ 2];
          
          forecasts.add(ForecastModel(
            date: DateTime.fromMillisecondsSinceEpoch(midDayData['dt'] * 1000),
            tempMin: minTemp,
            tempMax: maxTemp,
            weatherMain: dominantWeather,
            weatherDescription: midDayData['weather'][0]['description'],
            weatherIcon: midDayData['weather'][0]['icon'],
            humidity: totalHumidity ~/ dayData.length,
            precipitation: totalRain,
          ));
          
          count++;
        });
        
        return forecasts;
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Error processing forecast: $e');
    }
  }

  // Get weather by city name
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var weather = WeatherModel.fromJson(data);
        
        // Get location details for state name
        if (data['coord'] != null) {
          final locationDetails = await _locationService.getLocationName(
            data['coord']['lat'].toDouble(),
            data['coord']['lon'].toDouble(),
          );
          weather = weather.copyWith(stateName: locationDetails['state']);
        }
        
        return weather;
      } else {
        throw Exception('City not found');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }
}