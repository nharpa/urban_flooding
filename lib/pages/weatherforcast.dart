import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/weather_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:urban_flooding/data/api_services.dart';
import 'package:intl/intl.dart';

class WeatherForecastPage extends StatelessWidget {
  const WeatherForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WeatherCard(),
            const SizedBox(height: 24),
            const Text(
              'Chance of Rain',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: ChanceOfRain()),
            const SizedBox(height: 24),
            const Text(
              'Current Rainfall (mm)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: CurrentRainfall()),
          ],
        ),
      ),
    );
  }
}

class CurrentRainfall extends StatelessWidget {
  const CurrentRainfall({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: fetchRainfallObservationsForCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading rainfall data'));
        } else if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text('No rainfall data available'));
        }
        final observations = snapshot.data!;
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
                        angle: -0.785398, // -45 degrees in radians
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  reservedSize: 40,
                  interval: 1,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
          ),
        );
      },
    );
  }
}

class ChanceOfRain extends StatelessWidget {
  const ChanceOfRain({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: fetchChanceOfRainForecast(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        // Sort by start_time and take the last 7
        final data = List<Map<String, dynamic>>.from(snapshot.data!);
        data.sort((a, b) => a['start_time'].compareTo(b['start_time']));
        final last7 = data.length > 7 ? data.sublist(data.length - 7) : data;

        // Prepare chart data
        final spots = <FlSpot>[];
        final labels = <String>[];
        for (int i = 0; i < last7.length; i++) {
          final value = last7[i]['probability_of_precipitation'] ?? 0.0;
          final dateStr = last7[i]['start_time'] ?? '';
          String label = '';
          try {
            final date = DateTime.parse(dateStr);
            label = DateFormat('dd-MM').format(date);
          } catch (_) {
            label = dateStr;
          }
          spots.add(FlSpot(i.toDouble(), value.toDouble()));
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
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
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
      },
    );
  }
}
