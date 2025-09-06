import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// const String apiDomain = 'http://10.0.2.2:8000'; // Local Ip for Development
final String apiDomain = dotenv.env['API_DOMAIN'] ?? 'http://10.0.2.2:8000';

/// Gets the device's current location as a Position object.
Future<Position?> getCurrentDeviceLocation() async {
  try {
    final locationSettings = LocationSettings(accuracy: LocationAccuracy.high);
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  } catch (e) {
    // Handle error
    return null;
  }
}

/// Fetches probability_of_precipitation and start_time for the first 7 forecast periods.
Future<List<Map<String, dynamic>>?> fetchChanceOfRainForecast() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('$apiDomain/api/v1/forecast');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"lat": lat, "lon": lon}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic>? forecastData = data['data'] as List<dynamic>?;
      if (forecastData == null) return null;
      List<Map<String, dynamic>> result = [];
      for (int i = 0; i < forecastData.length && i < 7; i++) {
        final item = forecastData[i];
        String popStr =
            item['forecast']['probability_of_precipitation']?.toString() ??
            '0%';
        double pop = double.tryParse(popStr.replaceAll('%', '')) ?? 0.0;
        result.add({
          'probability_of_precipitation': pop,
          'start_time': item['start_time'],
        });
      }

      return result;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

/// Gets rainfall observation data for the current location for use in a rainfall bar chart.
Future<List<Map<String, dynamic>>?>
fetchRainfallObservationsForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('$apiDomain/api/v1/weather');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"lat": lat, "lon": lon}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final observations = data['data']?['observations'] as List<dynamic>?;
      if (observations == null) return null;
      // Extract local_date_time, local_date_time_full, and rain_trace for each observation
      List<Map<String, dynamic>> obsList = observations
          .map<Map<String, dynamic>>(
            (obs) => {
              'local_date_time': obs['local_date_time'],
              'local_date_time_full': obs['local_date_time_full'],
              'rain_trace': obs['rain_trace'],
            },
          )
          .toList();
      // Sort by local_date_time_full (assume ISO8601 string)
      obsList.sort(
        (a, b) =>
            a['local_date_time_full'].compareTo(b['local_date_time_full']),
      );
      // Convert rain_trace to increments (deltas)
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
      // Return only the last 13 values
      return obsList.length > 13
          ? obsList.sublist(obsList.length - 13)
          : obsList;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

/// Gets the device's current location and queries the forecast API.
Future<Map<String, dynamic>?> fetchWeatherConditionForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('$apiDomain/api/v1/weathercondition');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"lat": lat, "lon": lon}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
