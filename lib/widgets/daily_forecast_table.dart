import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/weather_icon.dart';

// Helper to extract and format daily forecast data for the table
List<Map<String, dynamic>> extractDailyForecast(
  Map<String, dynamic> dailyData,
) {
  final data = dailyData['data']?['forecastDays'] ?? [];

  if (data is! List) return [];

  final formattedData = data
      .map<Map<String, dynamic>>(
        (item) => {
          'date': item['interval']['displayDate'],
          'minTemp': item['maxTemperature']['degrees'],
          'maxTemp': item['minTemperature']['degrees'],
          'daytimeForecast': {
            'weatherCondition':
                item['daytimeForecast']['weatherCondition']['description']['text'],
            'icon': item['daytimeForecast']['weatherCondition']['iconBaseUri'],
            'humidity':
                item['daytimeForecast']['weatherCondition']['relativeHumidity'],
            'rainChance':
                item['daytimeForecast']['precipitation']['probability']['percent'],
            'rainAmount':
                item['daytimeForecast']['precipitation']['qpf']['quantity'],
          },
          'nighttimeForecast': {
            'weatherCondition':
                item['nighttimeForecast']['weatherCondition']['description']['text'],
            'icon':
                item['nighttimeForecast']['weatherCondition']['iconBaseUri'],
            'humidity':
                item['nighttimeForecast']['weatherCondition']['relativeHumidity'],
            'rainChance':
                item['nighttimeForecast']['precipitation']['probability']['percent'],
            'rainAmount':
                item['nighttimeForecast']['precipitation']['qpf']['quantity'],
          },
        },
      )
      .toList();
  print(formattedData);
  return formattedData;
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
                0: FixedColumnWidth(80), // Date
                1: FixedColumnWidth(40), // Min
                2: FixedColumnWidth(40), // Max
                3: FixedColumnWidth(40), // Day icon
                4: FixedColumnWidth(40), // Night icon
                5: FlexColumnWidth(), // Expand
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
                        'Day',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Night',
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
                        child: day['daytimeForecast']?['icon'] != null
                            ? WeatherIcon(
                                iconBaseUrl: day['daytimeForecast']['icon'],
                                size: 28,
                              )
                            : const SizedBox.shrink(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: day['nighttimeForecast']?['icon'] != null
                            ? WeatherIcon(
                                iconBaseUrl: day['nighttimeForecast']['icon'],
                                size: 28,
                              )
                            : const SizedBox.shrink(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _ForecastExpandIcon(day: day),
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

class _ForecastExpandIcon extends StatefulWidget {
  final Map<String, dynamic> day;
  const _ForecastExpandIcon({required this.day});

  @override
  State<_ForecastExpandIcon> createState() => _ForecastExpandIconState();
}

class _ForecastExpandIconState extends State<_ForecastExpandIcon> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day: ${widget.day['daytimeForecast']?['weatherCondition'] ?? ''}',
                ),
                Text(
                  '  Humidity: ${widget.day['daytimeForecast']?['humidity'] ?? ''}%',
                ),
                Text(
                  '  Rain: ${widget.day['daytimeForecast']?['rainChance'] ?? ''}% (${widget.day['daytimeForecast']?['rainAmount'] ?? ''} mm)',
                ),
                const SizedBox(height: 4),
                Text(
                  'Night: ${widget.day['nighttimeForecast']?['weatherCondition'] ?? ''}',
                ),
                Text(
                  '  Humidity: ${widget.day['nighttimeForecast']?['humidity'] ?? ''}%',
                ),
                Text(
                  '  Rain: ${widget.day['nighttimeForecast']?['rainChance'] ?? ''}% (${widget.day['nighttimeForecast']?['rainAmount'] ?? ''} mm)',
                ),
              ],
            ),
          ),
      ],
    );
  }
}
