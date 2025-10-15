import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:geolocator/geolocator.dart';

import 'package:urban_flooding/data/api_fetch_services.dart';

Position _fakePos() => Position(
      latitude: 10.0,
      longitude: 20.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

void main() {
  group('api_fetch_services', () {
    test('fetchHourlyForecastForCurrentLocation returns data on 200', () async {
      final client = MockClient((http.Request req) async {
        expect(req.url.path.endsWith('/api/v1/google/forecast/hourly'), isTrue);
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['lat'], isNotNull);
        expect(body['lon'], isNotNull);
        return http.Response(jsonEncode({'hourly': [1, 2, 3]}), 200);
      });
      final res = await fetchHourlyForecastForCurrentLocation(
        pos: _fakePos(),
        client: client,
      );
      expect(res, isNotNull);
      expect(res!['hourly'], isA<List>());
    });

    test('fetchDailyForecastForCurrentLocation returns null on non-200', () async {
      final client = MockClient((_) async => http.Response('nope', 404));
      final res = await fetchDailyForecastForCurrentLocation(
        pos: _fakePos(),
        client: client,
      );
      expect(res, isNull);
    });

    test('fetchRiskForCurrentLocation returns map on 200', () async {
      final client = MockClient((http.Request req) async {
        expect(req.url.path.endsWith('/api/v1/risk'), isTrue);
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['rainfall_event_id'], isNotNull);
        return http.Response(jsonEncode({'risk': {'level': 'low'}}), 200);
      });
      final res = await fetchRiskForCurrentLocation(
        rainfallEventId: 'current',
        lat: 10,
        lon: 20,
        client: client,
      );
      expect(res, isNotNull);
      expect(res!['risk'], isA<Map>());
    });

    test('fetchWeatherForCurrentLocation aggregates pieces', () async {
      final client = MockClient((http.Request req) async {
        final path = req.url.path;
        if (path.endsWith('/forecast/hourly')) {
          return http.Response(jsonEncode({'h': true}), 200);
        } else if (path.endsWith('/forecast/daily')) {
          return http.Response(jsonEncode({'d': true}), 200);
        } else if (path.endsWith('/conditions')) {
          return http.Response(jsonEncode({'c': true}), 200);
        } else if (path.endsWith('/history')) {
          return http.Response(jsonEncode({'hist': true}), 200);
        } else if (path.endsWith('/risk')) {
          return http.Response(jsonEncode({'r': true}), 200);
        }
        return http.Response('no', 404);
      });

      final result = await fetchWeatherForCurrentLocation(
        pos: _fakePos(),
        client: client,
      );

      expect(result, isNotNull);
      expect(result!['hourly'], isA<Map>());
      expect(result['daily'], isA<Map>());
      expect(result['conditions'], isA<Map>());
      expect(result['history'], isA<Map>());
      expect(result['risk'], isA<Map>());
    });
  });
}

