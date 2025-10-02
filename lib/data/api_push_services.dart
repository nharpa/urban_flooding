import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

// const String apiDomain = 'http://10.0.2.2:8000'; // Local Ip for Development
final String apiDomain = dotenv.env['API_DOMAIN'] ?? 'http://10.0.2.2:8000';
final String apiKey = dotenv.env['API_KEY'] ?? '';

Map<String, String> _authHeaders({Map<String, String>? extra}) {
  return {
    'Content-Type': 'application/json',
    if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
    ...?extra,
  };
}

/// Generic helper to POST arbitrary JSON data. Can be reused.
Future<http.Response> postJson(
  String path,
  Map<String, dynamic> body, {
  Map<String, String>? headers,
}) async {
  final resp = await http.post(
    Uri.parse('$apiDomain$path'),
    headers: _authHeaders(extra: headers),
    body: jsonEncode(body),
  );
  return resp;
}

/// Submit a user report to the backend API.
Future<Map<String, dynamic>?> submitUserReport({
  required String issueType,
  required String description,
  Position? pos, // allow caller to supply to avoid duplicate lookups
  String? userUid,
  String? userDisplayName,
  String? userEmail,
}) async {
  try {
    if (issueType.trim().isEmpty || description.trim().isEmpty) {
      return null;
    }

    final body = <String, dynamic>{
      'issue_type': issueType.trim(),
      'description': description.trim(),
      if (pos != null)
        'location': {'latitude': pos.latitude, 'longitude': pos.longitude},
      'user': {
        if (userUid != null && userUid.isNotEmpty) 'uid': userUid,
        if (userDisplayName != null && userDisplayName.isNotEmpty)
          'display_name': userDisplayName,
        if (userEmail != null && userEmail.isNotEmpty) 'email': userEmail,
      },
    };

    // Remove empty user object if nothing inside
    if ((body['user'] as Map).isEmpty) {
      body.remove('user');
    }

    print(body);
    final resp = await postJson('/api/v1/report', body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      try {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        return {'status': 'ok'}; // no JSON / invalid JSON fallback
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}
