import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Helper to extract and format rainfall data for the bar chart
List<Map<String, dynamic>> extractRainfallHistory(
  Map<String, dynamic> weatherData,
) {
  final data = weatherData['data'];
  final rainfallData = data['historyHours'] as List<dynamic>?;

  if (rainfallData == null || rainfallData.isEmpty) return [];

  List<Map<String, dynamic>> obsList = rainfallData
      .map<Map<String, dynamic>>(
        (obs) => {
          'local_date_time': obs['displayDateTime'],
          'Interval_start_time': obs['interval']['startTime'],
          'Interval_end_time': obs['interval']['endTime'],
          'rain': obs['precipitation']["probability"]["percent"],
          'rain_qpf': obs['precipitation']["qpf"]["quantity"],
        },
      )
      .toList();
  // Sort the list by Interval_start_time
  obsList.sort((a, b) {
    final DateTime timeA = DateTime.parse(a['Interval_start_time']);
    final DateTime timeB = DateTime.parse(b['Interval_start_time']);
    return timeA.compareTo(timeB);
  });

  final first14 = obsList.length > 14 ? obsList.sublist(0, 14) : obsList;
  return first14;
}

class CurrentRainfall extends StatelessWidget {
  final Map<String, dynamic> data;
  const CurrentRainfall({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final observations = extractRainfallHistory(data);
    if (observations.isEmpty) {
      return const Center(child: Text('No rainfall data available'));
    }

    // Prepare chart data and labels (same as ChanceOfRain)
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    for (int i = 0; i < observations.length; i++) {
      final rainQpfStr = observations[i]['rain_qpf']?.toString() ?? '0';
      final value = double.tryParse(rainQpfStr.replaceAll('%', '')) ?? 0.0;
      final dateMap =
          observations[i]['local_date_time'] as Map<String, dynamic>?;
      final dayStr = dateMap?['day']?.toString() ?? '';
      final monthStr = dateMap?['month']?.toString() ?? '';
      final hourStr = dateMap?['hours']?.toString() ?? '';
      final minStr = '00';
      String label = "$dayStr/$monthStr $hourStr:$minStr";
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: value, color: Colors.blue)],
        ),
      );
      labels.add(label);
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    int idx = value.toInt();
                    if (idx < 0 || idx >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Transform.rotate(
                      angle: -0.785398, // -45 degrees
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          labels[idx],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                  reservedSize: 60,
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
        ),
      ),
    );
  }
}
