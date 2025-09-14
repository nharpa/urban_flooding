import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:urban_flooding/data/api_services.dart';
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
    'pressure':
        data['airPressure']['meanSeaLevelMillibars'] *
        0.1, // Convert hPa to kPa
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
                Column(
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 10.0)),
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
                const SizedBox(width: 16),
                Expanded(
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

// Helper to extract and format chance of rain data for the line chart
List<Map<String, dynamic>> extractChanceOfRainData(
  Map<String, dynamic> weatherData,
) {
  final data = weatherData['data'];
  final rainfallData = data['forecastHours'] as List<dynamic>?;
  if (rainfallData == null || rainfallData.isEmpty) return [];
  List<Map<String, dynamic>> predList = rainfallData
      .map<Map<String, dynamic>>(
        (obs) => {
          'local_date_time': obs['displayDateTime'],
          'Interval_start_time': obs['interval']['startTime'],
          'Interval_end_time': obs['interval']['endTime'],
          'rain_probability': obs['precipitation']["probability"]["percent"],
          'rain_qpf': obs['precipitation']["qpf"]["quantity"],
        },
      )
      .toList();

  // Sort the list by Interval_start_time
  predList.sort((a, b) {
    final DateTime timeA = DateTime.parse(a['Interval_start_time']);
    final DateTime timeB = DateTime.parse(b['Interval_start_time']);
    return timeA.compareTo(timeB);
  });

  final first14 = predList.length > 14 ? predList.sublist(0, 14) : predList;
  return first14;
}

// Helper to extract and format rainfall data for the bar chart
List<Map<String, dynamic>> extractRainfallObservations(
  Map<String, dynamic> data,
) {
  final rainfallData = data['forecastHours'] as List<dynamic>?;
  if (rainfallData == null || rainfallData.isEmpty) return [];

  List<Map<String, dynamic>> obsList = rainfallData
      .map<Map<String, dynamic>>(
        (obs) => {
          'local_date_time': obs['displayDateTime'],
          'Interval_start_time': obs['interval']['startTime'],
          'Interval_end_time': obs['interval']['endTime'],
          'rain_trace': obs['precipitation']["probability"]["percent"],
          'rain_qpf': obs['precipitation']["qpf"]["quantity"],
        },
      )
      .toList();
  obsList.sort(
    (a, b) => a['Interval_start_time'].compareTo(b['Interval_start_time']),
  );
  double? prev;
  for (var obs in obsList) {
    double? current = double.tryParse(obs['rain_trace']?.toString() ?? '0');
    if (prev != null && current != null) {
      obs['rain_trace'] = (current - prev).clamp(0, double.infinity);
    } else {
      obs['rain_trace'] = 0.0;
    }
    prev = current;
  }
  print("here");
  return obsList.length > 13 ? obsList.sublist(obsList.length - 13) : obsList;
}

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
          final hourlyData = result['hourly'] ?? {};
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
                SizedBox(height: 200, child: ChanceOfRain(data: hourlyData)),
                const SizedBox(height: 24),
                const Text(
                  'Current Rainfall (mm)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 200, child: CurrentRainfall(data: hourlyData)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper to extract and format daily forecast data for the table
List<Map<String, dynamic>> extractDailyForecast(
  Map<String, dynamic> dailyData,
) {
  final data = dailyData['data']?['dailyForecasts'] ?? [];
  if (data is! List) return [];
  return data
      .map<Map<String, dynamic>>(
        (item) => {
          'date': item['date'],
          'minTemp': item['temperatureMin'],
          'maxTemp': item['temperatureMax'],
          'precipitation': item['precipitationProbability'],
          'icon': item['icon'],
          'description': item['description'],
        },
      )
      .toList();
}

class DailyForecastTable extends StatelessWidget {
  final Map<String, dynamic> dailyData;
  const DailyForecastTable({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    final forecast = extractDailyForecast(dailyData);
    if (forecast.isEmpty) {
      return const Center(child: Text('No daily forecast data available'));
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(80),
                1: FixedColumnWidth(40),
                2: FixedColumnWidth(40),
                3: FixedColumnWidth(40),
                4: FlexColumnWidth(),
              },
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Min',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Max',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Rain %',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(4.0), child: Text('')),
                  ],
                ),
                ...forecast.map(
                  (day) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(day['date'] ?? ''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          day['minTemp'] != null ? '${day['minTemp']}°' : '',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          day['maxTemp'] != null ? '${day['maxTemp']}°' : '',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          day['precipitation'] != null
                              ? '${day['precipitation']}%'
                              : '',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            if (day['icon'] != null)
                              WeatherIcon(iconBaseUrl: day['icon'], size: 28),
                            if (day['description'] != null)
                              Flexible(
                                child: Text(
                                  ' ${day['description']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
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

class ChanceOfRain extends StatelessWidget {
  final Map<String, dynamic> data;
  const ChanceOfRain({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final last24 = extractChanceOfRainData(data);
    if (last24.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    // Prepare chart data
    final spots = <FlSpot>[];
    final labels = <String>[];
    for (int i = 0; i < last24.length; i++) {
      final popStr = last24[i]['rain_probability']?.toString() ?? '0%';
      final value = double.tryParse(popStr.replaceAll('%', '')) ?? 0.0;
      final dayStr = last24[i]['local_date_time']['day'] ?? '';
      final monthStr = last24[i]['local_date_time']['month'] ?? '';
      final hourStr = last24[i]['local_date_time']['hours'] ?? '';
      final minStr = '00';

      String label = "$dayStr/$monthStr $hourStr:$minStr";
      spots.add(FlSpot(i.toDouble(), value));
      labels.add(label);
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60, // Added reserved size for more space
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int idx = value.toInt();
                    if (idx < 0 || idx >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Transform.rotate(
                      angle: -0.785398, // -45 degrees in radians
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          labels[idx],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: Colors.blue,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentRainfall extends StatelessWidget {
  final Map<String, dynamic> data;
  const CurrentRainfall({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final observations = extractRainfallObservations(data);
    if (observations.isEmpty) {
      return const Center(child: Text('No rainfall data available'));
    }
    return BarChart(
      BarChartData(
        barGroups: [
          for (int i = 0; i < observations.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY:
                      double.tryParse(
                        observations[i]['rain_trace'].toString(),
                      ) ??
                      0.0,
                  color: Colors.blue,
                ),
              ],
            ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                int idx = value.toInt();
                if (idx < 0 || idx >= observations.length) {
                  return const SizedBox.shrink();
                }
                String label =
                    observations[idx]['local_date_time']?.toString() ?? '';
                if (label.contains('/')) {
                  label = label.split('/').last;
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -0.785398,
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              reservedSize: 60,
              interval: 1,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
