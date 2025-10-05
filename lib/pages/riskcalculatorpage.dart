import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:urban_flooding/widgets/flood_risk_card.dart';
import 'package:urban_flooding/widgets/app_google_map.dart';

class RiskCalculatorPage extends StatefulWidget {
  const RiskCalculatorPage({super.key});

  @override
  State<RiskCalculatorPage> createState() => _RiskCalculatorPageState();
}

class _RiskCalculatorPageState extends State<RiskCalculatorPage> {
  bool useCurrentLocation = true;
  Position? selectedPosition;
  String selectedRainfallEvent = 'current';
  final TextEditingController customRainfallController =
      TextEditingController();

  final List<Map<String, String>> rainfallEvents = [
    {'name': '2-year return period design storm', 'id': 'design_2yr'},
    {'name': '10-year return period design storm', 'id': 'design_10yr'},
    {'name': '50-year return period design storm', 'id': 'design_50yr'},
    {'name': '100-year return period design storm', 'id': 'design_100yr'},
    {'name': 'Perth 2024 historical storm', 'id': 'perth_historical_2024'},
    {'name': 'Current Weather Observations', 'id': 'current'},
    {'name': 'Custom', 'id': 'custom'},
  ];

  void _showFloodRiskDialog(Position? pos, String rainfallEventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 400,
          child: FloodRiskCard(location: pos, rainfallEventId: rainfallEventId),
        ),
      ),
    );
  }

  // TODO: Implement map picker and geolocation logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flood Risk Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Embedded map picker
            SizedBox(
              height: 250,
              child: AppGoogleMap(
                initialLat: selectedPosition?.latitude ?? -31.95,
                initialLon: selectedPosition?.longitude ?? 115.86,
                initialZoom: selectedPosition != null ? 15.0 : 11.0,
                centerOnDevice: useCurrentLocation,
                selectedPoint: selectedPosition != null
                    ? LatLng(
                        selectedPosition!.latitude,
                        selectedPosition!.longitude,
                      )
                    : null,
                onTap: (latLng) {
                  setState(() {
                    selectedPosition = Position(
                      latitude: latLng.latitude,
                      longitude: latLng.longitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    );
                    useCurrentLocation = false;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: useCurrentLocation,
                  onChanged: (val) {
                    setState(() {
                      useCurrentLocation = val ?? true;
                      if (useCurrentLocation) selectedPosition = null;
                    });
                  },
                ),
                const Text('Use Current Location'),
              ],
            ),
            if (!useCurrentLocation && selectedPosition != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Lat: ${selectedPosition!.latitude.toStringAsFixed(5)}, '
                  'Lon: ${selectedPosition!.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRainfallEvent,
              decoration: const InputDecoration(labelText: 'Rainfall Event'),
              items: rainfallEvents
                  .map(
                    (event) => DropdownMenuItem<String>(
                      value: event['id'],
                      child: Text(event['name']!),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedRainfallEvent = val ?? 'current';
                });
              },
            ),
            if (selectedRainfallEvent == 'custom')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: customRainfallController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Rainfall Amount (mm/h)',
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // TODO: If not using current location, get selectedPosition from map picker
                  Position? pos;
                  if (useCurrentLocation) {
                    pos = null; // FloodRiskCard will use device location
                  } else {
                    pos = selectedPosition;
                  }
                  String rainfallEventId = selectedRainfallEvent;
                  if (rainfallEventId == 'custom') {
                    rainfallEventId = customRainfallController.text.trim();
                  }
                  _showFloodRiskDialog(pos, rainfallEventId);
                },
                child: const Text('Calculate Risk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
