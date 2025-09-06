import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// const String apiDomain = 'http://10.0.2.2:8000'; // Local Ip for Development
const String apiDomain = 'http://209.38.30.123:8000'; // Production IP

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
