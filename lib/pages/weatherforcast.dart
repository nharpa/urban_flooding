import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/weather_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:urban_flooding/data/api_services.dart';

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
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 10),
              FlSpot(1, 30),
              FlSpot(2, 50),
              FlSpot(3, 40),
              FlSpot(4, 80),
              FlSpot(5, 60),
              FlSpot(6, 20),
            ],
            isCurved: true,
            barWidth: 4,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(show: true),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
