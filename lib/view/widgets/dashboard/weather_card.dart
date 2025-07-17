// lib/view/widgets/dashboard/weather_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../view_model/dashboard/weather_view_model.dart';
import '../../../data/models/weather_model.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({Key? key}) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  void initState() {
    super.initState();
    // Initialize weather data when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initializeWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Consumer<WeatherViewModel>(
      builder: (context, weatherVM, child) {
        if (weatherVM.isLoading && weatherVM.currentWeather == null) {
          return _buildLoadingCard();
        }

        if (weatherVM.error != null && weatherVM.currentWeather == null) {
          return _buildErrorCard(weatherVM.error!);
        }

        if (weatherVM.currentWeather == null) {
          return _buildLoadingCard();
        }

        return _buildWeatherCard(weatherVM, isSmallScreen);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.orange),
          const SizedBox(height: 8),
          Text('Loading weather...', style: AppTextStyle.regular14),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 8),
          Text(
            'Unable to load weather',
            style: AppTextStyle.medium16.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: AppTextStyle.regular12.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<WeatherViewModel>().fetchWeatherData();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            child: Text('Retry', style: AppTextStyle.medium14),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(WeatherViewModel weatherVM, bool isSmallScreen) {
    final weather = weatherVM.currentWeather!;
    final useCelsius = weatherVM.useCelsius;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main weather section with gradient background
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientColors(weather.weatherCondition),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Location and refresh button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${weather.cityName}, ${weather.stateName}',
                              style: AppTextStyle.medium14.copyWith(
                                color: AppColors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: weatherVM.isLoading
                          ? null
                          : () => weatherVM.refreshWeather(),
                      icon: weatherVM.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              color: AppColors.white,
                              size: 20,
                            ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Weather icon and temperature
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Weather icon
                    SizedBox(
                      width: isSmallScreen ? 80 : 100,
                      height: isSmallScreen ? 80 : 100,
                      child: _getWeatherIcon(weather.weatherCondition),
                    ),
                    SizedBox(width: isSmallScreen ? 16 : 24),
                    // Temperature
                    GestureDetector(
                      onTap: () => weatherVM.toggleTemperatureUnit(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                useCelsius
                                    ? '${weather.temperature.round()}'
                                    : '${weather.temperatureF.round()}',
                                style: AppTextStyle.black32.copyWith(
                                  color: AppColors.white,
                                  fontSize: isSmallScreen ? 36 : 48,
                                ),
                              ),
                              Text(
                                useCelsius ? '°C' : '°F',
                                style: AppTextStyle.bold20.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            weather.weatherDescription,
                            style: AppTextStyle.regular14.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'H: ${useCelsius ? weather.tempMax.round() : weather.tempMaxF.round()}°',
                                style: AppTextStyle.regular12.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'L: ${useCelsius ? weather.tempMin.round() : weather.tempMinF.round()}°',
                                style: AppTextStyle.regular12.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Weather details
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  'Humidity',
                  '${weather.humidity}%',
                  Icons.water_drop_outlined,
                  isSmallScreen,
                ),
                _buildWeatherDetail(
                  'Precipitation',
                  '${weather.precipitation?.toStringAsFixed(1) ?? '0.0'}ml',
                  Icons.umbrella_outlined,
                  isSmallScreen,
                ),
                _buildWeatherDetail(
                  'Pressure',
                  '${weather.pressure}hpa',
                  Icons.compress,
                  isSmallScreen,
                ),
                _buildWeatherDetail(
                  'Wind',
                  '${weather.windSpeed.round()}m/s',
                  Icons.air,
                  isSmallScreen,
                ),
              ],
            ),
          ),
          
          // Forecast section
          if (weatherVM.forecast.isNotEmpty) ...[
            Divider(color: AppColors.divider, height: 1),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4 Day Forecast',
                    style: AppTextStyle.bold16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: weatherVM.forecast.map((forecast) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildForecastDay(forecast, useCelsius, isSmallScreen),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon, bool isSmallScreen) {
    return Column(
      children: [
        Icon(icon, color: AppColors.orange, size: isSmallScreen ? 20 : 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyle.regular10.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyle.medium12.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastDay(ForecastModel forecast, bool useCelsius, bool isSmallScreen) {
    final cardWidth = isSmallScreen ? 70.0 : 85.0;
    
    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            forecast.dayName.toUpperCase(),
            style: AppTextStyle.bold14.copyWith(
              color: AppColors.orange,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: isSmallScreen ? 35 : 40,
            height: isSmallScreen ? 35 : 40,
            child: _getSmallWeatherIcon(forecast.weatherCondition),
          ),
          const SizedBox(height: 8),
          Text(
            useCelsius
                ? '${forecast.tempMax.round()}°C'
                : '${forecast.tempMaxF.round()}°F',
            style: AppTextStyle.medium12.copyWith(
              color: AppColors.textPrimary,
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
          Text(
            useCelsius
                ? '${forecast.tempMin.round()}°C'
                : '${forecast.tempMinF.round()}°F',
            style: AppTextStyle.regular10.copyWith(
              color: AppColors.textSecondary,
              fontSize: isSmallScreen ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

  // Get gradient colors based on weather condition
  List<Color> _getGradientColors(String condition) {
    switch (condition) {
      case 'clear':
        return [AppColors.orange.withOpacity(0.8), AppColors.orange];
      case 'partly_cloudy':
        return [AppColors.orange.withOpacity(0.6), AppColors.originalOrange];
      case 'cloudy':
        return [AppColors.grey.withOpacity(0.6), AppColors.darkGrey];
      case 'rain':
        return [AppColors.blue.withOpacity(0.6), AppColors.blue];
      case 'thunderstorm':
        return [AppColors.darkGrey, AppColors.black.withOpacity(0.8)];
      case 'snow':
        return [AppColors.lightBlue.withOpacity(0.3), AppColors.lightBlue.withOpacity(0.6)];
      case 'fog':
        return [AppColors.grey.withOpacity(0.4), AppColors.grey.withOpacity(0.6)];
      default:
        return [AppColors.orange.withOpacity(0.6), AppColors.orange];
    }
  }

  // Get weather icon widget based on condition
  Widget _getWeatherIcon(String condition) {
    String assetPath;
    switch (condition) {
      case 'clear':
        assetPath = 'assets/images/weather/sun.png';
        break;
      case 'partly_cloudy':
        assetPath = 'assets/images/weather/partly_cloudy.png';
        break;
      case 'cloudy':
        assetPath = 'assets/images/weather/cloudy.png';
        break;
      case 'rain':
        assetPath = 'assets/images/weather/rain.png';
        break;
      case 'thunderstorm':
        assetPath = 'assets/images/weather/thunderstorm.png';
        break;
      case 'snow':
        assetPath = 'assets/images/weather/snow.png';
        break;
      case 'fog':
        assetPath = 'assets/images/weather/fog.png';
        break;
      default:
        assetPath = 'assets/images/weather/sun.png';
    }
    
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon if asset is not found
        return Icon(
          _getFallbackIcon(condition),
          size: 80,
          color: AppColors.white,
        );
      },
    );
  }

  Widget _getSmallWeatherIcon(String condition) {
    String assetPath;
    switch (condition) {
      case 'clear':
        assetPath = 'assets/images/weather/sun.png';
        break;
      case 'partly_cloudy':
        assetPath = 'assets/images/weather/partly_cloudy.png';
        break;
      case 'cloudy':
        assetPath = 'assets/images/weather/cloudy.png';
        break;
      case 'rain':
        assetPath = 'assets/images/weather/rain.png';
        break;
      case 'thunderstorm':
        assetPath = 'assets/images/weather/thunderstorm.png';
        break;
      case 'snow':
        assetPath = 'assets/images/weather/snow.png';
        break;
      case 'fog':
        assetPath = 'assets/images/weather/fog.png';
        break;
      default:
        assetPath = 'assets/images/weather/sun.png';
    }
    
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon if asset is not found
        return Icon(
          _getFallbackIcon(condition),
          size: 32,
          color: AppColors.orange,
        );
      },
    );
  }

  IconData _getFallbackIcon(String condition) {
    switch (condition) {
      case 'clear':
        return Icons.wb_sunny;
      case 'partly_cloudy':
        return Icons.wb_cloudy;
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_sunny;
    }
  }
}