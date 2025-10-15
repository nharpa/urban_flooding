import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:geolocator/geolocator.dart';

import 'package:urban_flooding/data/api_post_services.dart';

void main() {
  group('submitUserReport', () {
    test('returns parsed JSON on 200 OK and sends expected payload', () async {
      Map<String, dynamic>? capturedBody;
      final client = MockClient((http.Request request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'result': 'ok', 'id': '123'}), 200);
      });

      final pos = Position(
        latitude: 1.23,
        longitude: 4.56,
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final res = await submitUserReport(
        issueType: '  Flood  ',
        description: '  Water on road  ',
        pos: pos,
        userUid: 'uid1',
        userDisplayName: 'Tester',
        userEmail: 'tester@example.com',
        client: client,
      );

      expect(res, isNotNull);
      expect(res!['result'], 'ok');
      expect(res['id'], '123');

      // Validate payload sent
      expect(capturedBody, isNotNull);
      expect(capturedBody!['issue_type'], 'Flood');
      expect(capturedBody!['description'], 'Water on road');
      expect(capturedBody!['location'], isA<Map<String, dynamic>>());
      expect(capturedBody!['location']['latitude'], closeTo(1.23, 1e-9));
      expect(capturedBody!['location']['longitude'], closeTo(4.56, 1e-9));
      expect(capturedBody!['user'], isA<Map<String, dynamic>>());
      expect(capturedBody!['user']['uid'], 'uid1');
      expect(capturedBody!['user']['display_name'], 'Tester');
      expect(capturedBody!['user']['email'], 'tester@example.com');
    });

    test('returns null on non-2xx', () async {
      final client = MockClient((_) async => http.Response('nope', 500));
      final res = await submitUserReport(
        issueType: 'Flood',
        description: 'Something',
        client: client,
      );
      expect(res, isNull);
    });

    test('returns null when required fields are empty', () async {
      final client = MockClient((_) async => http.Response('{}', 200));
      final res = await submitUserReport(
        issueType: '   ',
        description: '',
        client: client,
      );
      expect(res, isNull);
    });
  });
}

