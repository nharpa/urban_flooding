import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
