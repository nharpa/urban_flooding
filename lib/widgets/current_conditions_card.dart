import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/weather_icon.dart';

String? _windCardinalShort(String? cardinal) {
  if (cardinal == null) return null;
  const map = {
    'NORTH': 'N',
    'NORTHEAST': 'NE',
    'EAST': 'E',
    'SOUTHEAST': 'SE',
    'SOUTH': 'S',
    'SOUTHWEST': 'SW',
    'WEST': 'W',
    'NORTHWEST': 'NW',
    'NORTH_NORTHEAST': 'NNE',
    'EAST_NORTHEAST': 'ENE',
    'EAST_SOUTHEAST': 'ESE',
    'SOUTH_SOUTHEAST': 'SSE',
    'SOUTH_SOUTHWEST': 'SSW',
    'WEST_SOUTHWEST': 'WSW',
    'WEST_NORTHWEST': 'WNW',
    'NORTH_NORTHWEST': 'NNW',
  };
  return map[cardinal] ?? cardinal;
}

// Helper to extract and format current conditions data for the card
Map<String, dynamic> extractConditions(Map<String, dynamic> conditionsData) {
  final data = conditionsData['data']?['weatherConditions'] ?? {};
  final wind = data['wind'] ?? {};
  final windDir = wind['direction'] ?? {};
  final windSpeed = wind['speed'] ?? {};
  return {
    'temperature': data['temperature']['degrees'],
    'humidity': data['relativeHumidity'],
    'windDirection': _windCardinalShort(windDir['cardinal']),
    'windSpeed': windSpeed['value'],
    'windSpeedUnit': windSpeed['unit'],
    'description': data['weatherCondition']['description']['text'],
    'icon': data['weatherCondition']['iconBaseUri'],
    'feelsLike': data['feelsLikeTemperature']['degrees'],
    'pressure': double.parse(
      (data['airPressure']['meanSeaLevelMillibars'] * 0.1).toStringAsFixed(2),
    ), // Convert hPa to kPa and round to 2 decimals
    'uvIndex': data['uvIndex'],
    'visibility': data['visibility']['distance'],
  };
}

class CurrentConditionsCard extends StatelessWidget {
  final Map<String, dynamic> conditionsData;
  const CurrentConditionsCard({super.key, required this.conditionsData});

  @override
  Widget build(BuildContext context) {
    final cond = extractConditions(conditionsData);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Conditions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(padding: const EdgeInsets.only(top: 16.0)),
                      if (cond['icon'] != null)
                        WeatherIcon(iconBaseUrl: cond['icon'], size: 48),
                      if (cond['description'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            cond['description'],
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cond['temperature'] != null)
                        Text(
                          'Temperature: ${cond['temperature']}°C \n${cond['feelsLike'] != null ? '(Feels like: ${cond['feelsLike']}°C)' : ''}',
                        ),
                      if (cond['humidity'] != null)
                        Text('Humidity: ${cond['humidity']}%'),
                      if (cond['windDirection'] != null &&
                          cond['windSpeed'] != null)
                        Text(
                          'Wind: ${cond['windDirection']} ${cond['windSpeed']} km/h',
                        ),
                      if (cond['pressure'] != null)
                        Text('Pressure: ${cond['pressure']} kPa'),
                      if (cond['uvIndex'] != null)
                        Text('UV Index: ${cond['uvIndex']}'),
                      if (cond['visibility'] != null)
                        Text('Visibility: ${cond['visibility']} km'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
