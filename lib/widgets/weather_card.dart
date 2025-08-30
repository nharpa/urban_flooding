import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherData {
  final String temperature;
  final String condition;
  final String floodRisk;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.floodRisk,
  });
}

WeatherData getPlaceholderWeatherData() {
  // Later replace with API call
  return WeatherData(
    temperature: '30°C',
    condition: 'Cloudy',
    floodRisk: 'Moderate',
  );
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String _getWeatherIconAsset(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return 'lib/assets/weather_sunny.svg';
      case 'rainy':
        return 'lib/assets/weather_rainy.svg';
      case 'cloudy':
      default:
        return 'lib/assets/weather_cloudy.svg';
    }
  }

  late WeatherData weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getPlaceholderWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[75],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey, width: 2),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            _getWeatherIconAsset(weatherData.condition),
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Weather Conditions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Temperature: ${weatherData.temperature}'),
                Text('Conditions: ${weatherData.condition}'),
                Text('Flood Risk: ${weatherData.floodRisk}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
