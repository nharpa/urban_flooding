import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// const String apiDomain = 'http://10.0.2.2:8000'; // Local Ip for Development
final String apiDomain = dotenv.env['API_DOMAIN'] ?? 'http://10.0.2.2:8000';
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
Future<Map<String, dynamic>?> fetchHourlyForecastForCurrentLocation({
  Position? pos,
  http.Client? client,
}) async {
  try {
    Position? position = pos ?? await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;
    final http.Client c = client ?? http.Client();
    final response = await c.post(
      Uri.parse('$apiDomain/api/v1/google/forecast/hourly'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({"lat": lat, "lon": lon}),
    );
    if (client == null) c.close();
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
Future<Map<String, dynamic>?> fetchDailyForecastForCurrentLocation({
  Position? pos,
  http.Client? client,
}) async {
  try {
    Position? position = pos ?? await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;
    final http.Client c = client ?? http.Client();
    final response = await c.post(
      Uri.parse('$apiDomain/api/v1/google/forecast/daily'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({"lat": lat, "lon": lon}),
    );
    if (client == null) c.close();
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
Future<Map<String, dynamic>?> fetchWeatherConditionForCurrentLocation({
  Position? pos,
  http.Client? client,
}) async {
  try {
    Position? position = pos ?? await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('$apiDomain/api/v1/google/conditions');
    final http.Client c = client ?? http.Client();
    final response = await c.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({"lat": lat, "lon": lon}),
    );
    if (client == null) c.close();

    Map<String, dynamic>? weatherData;
    if (response.statusCode == 200) {
      weatherData = jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    } // Fetch risk data and append to weatherData
    return weatherData;
  } catch (e) {
    return null;
  }
}

/// Gets the device's current location and queries the forecast API.
Future<Map<String, dynamic>?> fetchWeatherHistoryForCurrentLocation({
  Position? pos,
  http.Client? client,
}) async {
  try {
    Position? position = pos ?? await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('$apiDomain/api/v1/google/history');
    final http.Client c = client ?? http.Client();
    final response = await c.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({"lat": lat, "lon": lon}),
    );
    if (client == null) c.close();

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

/// Fetches warnings from the API for the current device location.
Future<Map<String, dynamic>?> fetchWarningsForCurrentLocation({
  Position? pos,
  http.Client? client,
}) async {
  try {
    Position? position = pos ?? await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;
    final http.Client c = client ?? http.Client();
    final response = await c.post(
      Uri.parse('$apiDomain/api/v1/warnings'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({"lat": lat, "lon": lon}),
    );
    if (client == null) c.close();
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

/// Fetches risk data from the API for the current device location.
Future<Map<String, dynamic>?> fetchRiskForCurrentLocation({
  String? rainfallEventId,
  double? lat,
  double? lon,
  http.Client? client,
}) async {
  try {
    double latitude;
    double longitude;
    if (lat != null && lon != null) {
      latitude = lat;
      longitude = lon;
    } else {
      Position? position = await getCurrentDeviceLocation();
      if (position == null) return null;
      latitude = position.latitude;
      longitude = position.longitude;
    }

    final http.Client c = client ?? http.Client();
    final response = await c.post(
      Uri.parse('$apiDomain/api/v1/risk'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "lat": latitude,
        "lon": longitude,
        "rainfall_event_id": rainfallEventId ?? "none",
      }),
    );
    if (client == null) c.close();
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
Future<Map<String, dynamic>?> fetchWeatherForCurrentLocation({
  Position? pos,
  http.Client? client,
}) async {
  try {
    final results = await Future.wait([
      fetchHourlyForecastForCurrentLocation(pos: pos, client: client),
      fetchDailyForecastForCurrentLocation(pos: pos, client: client),
      fetchWeatherConditionForCurrentLocation(pos: pos, client: client),
      fetchWeatherHistoryForCurrentLocation(pos: pos, client: client),
      fetchRiskForCurrentLocation(rainfallEventId: "current", client: client),
    ]);
    final hourly = results[0];
    final daily = results[1];
    final conditions = results[2];
    final history = results[3];
    final risk = results[4];
    return {
      'hourly': hourly,
      'daily': daily,
      'conditions': conditions,
      'history': history,
      'risk': risk,
    };
  } catch (e) {
    return null;
  }
}
