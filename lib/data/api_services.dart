import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String apiDomain = 'http://10.0.2.2:8000'; // Local Ip for Development
// final String apiDomain = dotenv.env['API_DOMAIN'] ?? 'http://10.0.2.2:8000';
final String apiKey = dotenv.env['API_KEY'] ?? '';

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

/// Fetches the hourly forecast for the current location.
Future<Map<String, dynamic>?> fetchHourlyForecastForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final response = await http.post(
      Uri.parse('$apiDomain/api/v1/google/forecast/hourly'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
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

/// Fetches the daily forecast for the current location.
Future<Map<String, dynamic>?> fetchDailyForecastForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final response = await http.post(
      Uri.parse('$apiDomain/api/v1/google/forecast/daily'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
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

/// Gets the device's current location and queries the forecast API.
Future<Map<String, dynamic>?> fetchWeatherConditionForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('$apiDomain/api/v1/google/conditions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
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

/// Gets the device's current location and queries the forecast API.
Future<Map<String, dynamic>?> fetchWeatherHistoryForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('$apiDomain/api/v1/google/history');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
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

/// Fetches all weather, hourly forecast, daily forecast, and rainfall data for the current location in a single call.
Future<Map<String, dynamic>?> fetchWeatherForCurrentLocation() async {
  try {
    final results = await Future.wait([
      fetchHourlyForecastForCurrentLocation(),
      fetchDailyForecastForCurrentLocation(),
      fetchWeatherConditionForCurrentLocation(),
      fetchWeatherHistoryForCurrentLocation(),
    ]);
    final hourly = results[0];
    final daily = results[1];
    final conditions = results[2];
    final history = results[3];
    return {
      'hourly': hourly,
      'daily': daily,
      'conditions': conditions,
      'history': history,
    };
  } catch (e) {
    return null;
  }
}

/// Fetches warnings from the API for the current device location.
Future<Map<String, dynamic>?> fetchForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final response = await http.post(
      Uri.parse('$apiDomain/api/v1/warnings'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
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
