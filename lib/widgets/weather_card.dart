import 'package:flutter/material.dart';
import 'package:urban_flooding/data/api_services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String floodRisk;
  final String forecastIconCode;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.floodRisk,
    required this.forecastIconCode,
  });
}

Future<WeatherData?> getWeatherForecast() async {
  final forecast = await fetchWeatherConditionForCurrentLocation();
  if (forecast == null) return null;

  String precis = forecast['data']['precis'];
  double temperature = forecast['data']['temperature'];
  String forecastIconCode = forecast['data']['forecast_icon_code'];
  // String floodRisk = forecast['data']['floodRisk'];

  WeatherData response = WeatherData(
    temperature: temperature,
    condition: precis,
    floodRisk: 'tbc',
    forecastIconCode: forecastIconCode,
  );

  return response;
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String _getWeatherIconAsset(String? forecastIconCode) {
    if (forecastIconCode == null || forecastIconCode.isEmpty) {
      return 'lib/assets/1.svg';
    }
    // todo: make sure all possible forecastIconCodes are handled
    return 'lib/assets/$forecastIconCode.svg';
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
                _getWeatherIconAsset(weatherData.forecastIconCode),
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Column(
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
            ],
          ),
        );
      },
    );
  }
}
