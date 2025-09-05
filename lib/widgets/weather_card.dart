import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:urban_flooding/data/services/api_services.dart';

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

Future<WeatherData?> getWeatherForecast() async {
  final forecast = await fetchForecastForCurrentLocation();
  if (forecast == null) return null;
  String precis = forecast['data'][0]['forecast']['precis'];

  print(forecast['data'][0]['forecast']);

  return WeatherData(temperature: '17°C', condition: precis, floodRisk: 'high');
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData?>(
      future: getWeatherForecast(),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
      },
    );
  }
}
