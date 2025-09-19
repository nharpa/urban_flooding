import 'package:flutter/material.dart';
import 'package:urban_flooding/data/api_services.dart';
import 'package:urban_flooding/widgets/chance_of_rain.dart';
import 'package:urban_flooding/widgets/current_conditions_card.dart';
import 'package:urban_flooding/widgets/current_rainfall.dart';
import 'package:urban_flooding/widgets/daily_forecast_table.dart';

class WeatherForecastPage extends StatelessWidget {
  const WeatherForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchWeatherForCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading weather data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No weather data available'));
          }
          final result = snapshot.data!;
          final forecastHourlyData = result['hourly'] ?? {};
          final historyHourlyData = result['history'] ?? {};
          final dailyData = result['daily'] ?? {};
          final conditionsData = result['conditions'] ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CurrentConditionsCard(conditionsData: conditionsData),
                DailyForecastTable(dailyData: dailyData),
                const SizedBox(height: 24),
                const Text(
                  'Chance of Rain',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ChanceOfRain(data: forecastHourlyData),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Current Rainfall (mm)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: CurrentRainfall(data: historyHourlyData),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
