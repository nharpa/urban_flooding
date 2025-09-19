import 'package:flutter/material.dart';
import 'package:urban_flooding/theme/theme.dart';
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
          'date': item['displayDate'],
          'minTemp': item['maxTemperature']['degrees'],
          'maxTemp': item['minTemperature']['degrees'],
          'daytimeForecast': {
            'weatherCondition':
                item['daytimeForecast']['weatherCondition']['description']['text'],
            'icon': item['daytimeForecast']['weatherCondition']['iconBaseUri'],
            'humidity': item['daytimeForecast']['relativeHumidity'],
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
            'humidity': item['nighttimeForecast']['relativeHumidity'],
            'rainChance':
                item['nighttimeForecast']['precipitation']['probability']['percent'],
            'rainAmount':
                item['nighttimeForecast']['precipitation']['qpf']['quantity'],
          },
        },
      )
      .toList();

  return formattedData;
}

String formatDisplayDate(Map<String, dynamic>? dateMap) {
  if (dateMap == null) return '';
  final year = dateMap['year'] as int?;
  final month = dateMap['month'] as int?;
  final day = dateMap['day'] as int?;
  if (year == null || month == null || day == null) return '';
  final date = DateTime(year, month, day);
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weekday = weekdays[date.weekday - 1];
  return '$weekday $day/$month';
}

String formatDialogDate(Map<String, dynamic>? dateMap) {
  if (dateMap == null) return '';
  final year = dateMap['year'] as int?;
  final month = dateMap['month'] as int?;
  final day = dateMap['day'] as int?;
  if (year == null || month == null || day == null) return '';
  final date = DateTime(year, month, day);
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  String suffix(int d) {
    if (d >= 11 && d <= 13) return 'th';
    switch (d % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  final weekday = weekdays[date.weekday - 1];
  final monthName = months[month];
  return '$weekday $day${suffix(day)} $monthName $year';
}

class DailyForecastTable extends StatelessWidget {
  final Map<String, dynamic> dailyData;
  const DailyForecastTable({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    final forecast = extractDailyForecast(dailyData);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark
        ? AppTheme.forecastTableHeaderDark
        : AppTheme.forecastTableHeaderLight;
    final borderColor = isDark
        ? AppTheme.forecastTableBorderDark
        : AppTheme.forecastTableBorderLight;
    final rowColor = isDark
        ? AppTheme.forecastTableRowDark
        : AppTheme.forecastTableRowLight;
    final textColor = isDark
        ? AppTheme.forecastTableTextDark
        : AppTheme.forecastTableTextLight;
    if (forecast.isEmpty) {
      return Center(
        child: Text(
          'No daily forecast data available',
          style: TextStyle(color: textColor),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(80), // Date
                1: FixedColumnWidth(50), // Min
                2: FixedColumnWidth(50), // Max
                3: FixedColumnWidth(50), // Day icon
                4: FixedColumnWidth(50), // Night icon
                5: FlexColumnWidth(), // Expand
              },
              border: TableBorder.all(color: borderColor),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: headerColor),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Max',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Night',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(''),
                    ),
                  ],
                ),
                ...forecast.map(
                  (day) => TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          formatDisplayDate(
                            day['date'] as Map<String, dynamic>?,
                          ),
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          day['minTemp'] != null ? '${day['minTemp']}°' : '',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          day['maxTemp'] != null ? '${day['maxTemp']}°' : '',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: day['daytimeForecast']?['icon'] != null
                            ? WeatherIcon(
                                iconBaseUrl: day['daytimeForecast']['icon'],
                                size: 28,
                              )
                            : const SizedBox.shrink(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: day['nighttimeForecast']?['icon'] != null
                            ? WeatherIcon(
                                iconBaseUrl: day['nighttimeForecast']['icon'],
                                size: 28,
                              )
                            : const SizedBox.shrink(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconButton(
                          icon: Icon(Icons.info_outline, color: textColor),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => _ForecastDetailsDialog(
                              day: day,
                              textColor: textColor,
                            ),
                          ),
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

class _ForecastDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> day;
  final Color textColor;
  const _ForecastDetailsDialog({required this.day, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 24,
      ), // reduce space around dialog
      content: SizedBox(
        width: 800, // make dialog card even wider
        child: Card(
          color: Theme.of(context).cardColor,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDialogDate(day['date'] as Map<String, dynamic>?),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1, // wider day column
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (day['daytimeForecast']?['icon'] != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: WeatherIcon(
                                iconBaseUrl: day['daytimeForecast']['icon'],
                                size: 48,
                              ),
                            ),
                          if (day['daytimeForecast']?['weatherCondition'] !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day['daytimeForecast']['weatherCondition'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Humidity: ${day['daytimeForecast']?['humidity'] ?? ''}%',
                            style: TextStyle(color: textColor),
                          ),
                          Text(
                            'Rain: ${day['daytimeForecast']?['rainChance'] ?? ''}% (${(day['daytimeForecast']?['rainAmount'] != null ? (day['daytimeForecast']['rainAmount'] as num).toStringAsFixed(2) : '')} mm)',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 1, // wider night column
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Night',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (day['nighttimeForecast']?['icon'] != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: WeatherIcon(
                                iconBaseUrl: day['nighttimeForecast']['icon'],
                                size: 48,
                              ),
                            ),
                          if (day['nighttimeForecast']?['weatherCondition'] !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day['nighttimeForecast']['weatherCondition'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Humidity: ${day['nighttimeForecast']?['humidity'] ?? ''}%',
                            style: TextStyle(color: textColor),
                          ),
                          Text(
                            'Rain: ${day['nighttimeForecast']?['rainChance'] ?? ''}% (${(day['nighttimeForecast']?['rainAmount'] != null ? (day['nighttimeForecast']['rainAmount'] as num).toStringAsFixed(2) : '')} mm)',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyle(color: textColor)),
        ),
      ],
    );
  }
}
