// lib/data/models/weather_model.dart

class WeatherModel {
  final String cityName;
  final String stateName;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final DateTime timestamp;
  final double? precipitation;
  final int? visibility;
  final DateTime? sunrise;
  final DateTime? sunset;

  WeatherModel({
    required this.cityName,
    required this.stateName,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.timestamp,
    this.precipitation,
    this.visibility,
    this.sunrise,
    this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      stateName: '', // Will be set from geocoding
      temperature: (json['main']['temp'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'],
      weatherMain: json['weather'][0]['main'],
      weatherDescription: json['weather'][0]['description'],
      weatherIcon: json['weather'][0]['icon'],
      timestamp: DateTime.now(),
      precipitation: json['rain']?['1h']?.toDouble() ?? json['snow']?['1h']?.toDouble(),
      visibility: json['visibility'],
      sunrise: json['sys']['sunrise'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000)
          : null,
      sunset: json['sys']['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000)
          : null,
    );
  }

  WeatherModel copyWith({String? stateName}) {
    return WeatherModel(
      cityName: cityName,
      stateName: stateName ?? this.stateName,
      temperature: temperature,
      tempMin: tempMin,
      tempMax: tempMax,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      weatherMain: weatherMain,
      weatherDescription: weatherDescription,
      weatherIcon: weatherIcon,
      timestamp: timestamp,
      precipitation: precipitation,
      visibility: visibility,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  // Convert temperature to Fahrenheit
  double get temperatureF => (temperature * 9 / 5) + 32;
  double get tempMinF => (tempMin * 9 / 5) + 32;
  double get tempMaxF => (tempMax * 9 / 5) + 32;
  double get feelsLikeF => (feelsLike * 9 / 5) + 32;

  // Convert wind speed to mph
  double get windSpeedMph => windSpeed * 2.237;

  // Get weather condition for icon mapping
  String get weatherCondition {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return 'clear';
      case 'clouds':
        if (weatherDescription.contains('few clouds') || 
            weatherDescription.contains('scattered clouds')) {
          return 'partly_cloudy';
        }
        return 'cloudy';
      case 'rain':
        return 'rain';
      case 'drizzle':
        return 'rain';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snow':
        return 'snow';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'fog';
      default:
        return 'clear';
    }
  }
}

class ForecastModel {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final int humidity;
  final double? precipitation;

  ForecastModel({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.humidity,
    this.precipitation,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: (json['temp']['min'] as num).toDouble(),
      tempMax: (json['temp']['max'] as num).toDouble(),
      weatherMain: json['weather'][0]['main'],
      weatherDescription: json['weather'][0]['description'],
      weatherIcon: json['weather'][0]['icon'],
      humidity: json['humidity'],
      precipitation: json['rain']?.toDouble() ?? json['snow']?.toDouble(),
    );
  }

  // Convert temperature to Fahrenheit
  double get tempMinF => (tempMin * 9 / 5) + 32;
  double get tempMaxF => (tempMax * 9 / 5) + 32;

  // Get weather condition for icon mapping
  String get weatherCondition {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return 'clear';
      case 'clouds':
        if (weatherDescription.contains('few clouds') || 
            weatherDescription.contains('scattered clouds')) {
          return 'partly_cloudy';
        }
        return 'cloudy';
      case 'rain':
        return 'rain';
      case 'drizzle':
        return 'rain';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snow':
        return 'snow';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'fog';
      default:
        return 'clear';
    }
  }

  String get dayName {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[date.weekday - 1];
  }
}

class LocationModel {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? stateName;
  final String? countryCode;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.stateName,
    this.countryCode,
  });
}