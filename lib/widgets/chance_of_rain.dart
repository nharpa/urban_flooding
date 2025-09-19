import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
