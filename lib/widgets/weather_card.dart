import 'package:flutter/material.dart';
import 'package:urban_flooding/data/api_fetch_services.dart';
import 'package:urban_flooding/widgets/weather_icon.dart';

class WeatherData {
  final double temperature;
  final double feelsLike;
  final String condition;
  final String floodRisk;
  final String conditionIconCode;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.floodRisk,
    required this.conditionIconCode,
  });
}

Future<WeatherData?> getWeatherConditions() async {
  final response = await fetchWeatherConditionForCurrentLocation();
  if (response == null) return null;

  final conditions = response['data']['conditions'];
  String condition = conditions['condition'];
  String forecastIconUri = conditions['forecast_icon_uri'];
  double temperature = (conditions['temperature'] is int)
      ? (conditions['temperature'] as int).toDouble()
      : (conditions['temperature'] is double)
      ? conditions['temperature']
      : double.tryParse(conditions['temperature'].toString()) ?? 0.0;

  double feelsLike = (conditions['feels_like'] is int)
      ? (conditions['feels_like'] as int).toDouble()
      : (conditions['feels_like'] is double)
      ? conditions['feels_like']
      : double.tryParse(conditions['feels_like'].toString()) ?? 0.0;

  // Use the floodRisk value from the API response
  String floodRisk = response['floodRisk']?.toString() ?? 'Unknown';

  WeatherData weatherData = WeatherData(
    temperature: temperature,
    feelsLike: feelsLike,
    condition: condition,
    floodRisk: floodRisk,
    conditionIconCode: forecastIconUri,
  );

  return weatherData;
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

bool isDayTime() {
  final now = DateTime.now();
  return now.hour >= 6 && now.hour < 18; // 6am–6pm = day
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData?>(
      future: getWeatherConditions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading weather data'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No weather data available'));
        }
        final weatherData = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[75],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey, width: 2),
          ),
          child: Row(
            children: [
              WeatherIcon(iconBaseUrl: weatherData.conditionIconCode, size: 52),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Weather Conditions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temperature: ${weatherData.temperature} (Feels Like: ${weatherData.feelsLike})',
                  ),
                  Text('Conditions: ${weatherData.condition}'),
                  Text('Flood Risk: ${weatherData.floodRisk}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
