import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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

/// Gets the device's current location and queries the forecast API.
Future<Map<String, dynamic>?> fetchWeatherConditionForCurrentLocation() async {
  try {
    Position? position = await getCurrentDeviceLocation();
    if (position == null) return null;
    double lat = position.latitude;
    double lon = position.longitude;

    final url = Uri.parse('http://10.0.2.2:8000/api/v1/weathercondition');
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
