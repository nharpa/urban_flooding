import 'package:flutter/material.dart';
import 'package:urban_flooding/data/api_fetch_services.dart';
import 'package:geolocator/geolocator.dart';

class FloodRiskCard extends StatefulWidget {
  final Position? location;
  final String? rainfallEventId;

  const FloodRiskCard({super.key, this.location, this.rainfallEventId});

  @override
  State<FloodRiskCard> createState() => _FloodRiskCardState();
}

class _FloodRiskCardState extends State<FloodRiskCard> {
  Future<Map<String, dynamic>?>? _riskFuture;

  @override
  void initState() {
    super.initState();
    _riskFuture = _fetchRisk();
  }

  Future<Map<String, dynamic>?> _fetchRisk() async {
    if (widget.location != null) {
      return await fetchRiskForCurrentLocation(
        rainfallEventId: widget.rainfallEventId ?? "current",
        lat: widget.location!.latitude,
        lon: widget.location!.longitude,
      );
    } else {
      return await fetchRiskForCurrentLocation(
        rainfallEventId: widget.rainfallEventId ?? "current",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _riskFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error loading flood risk data'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No flood risk data available'),
            ),
          );
        }
        final rawData = snapshot.data!;

        final data = rawData['data'] ?? {};
        final parameters = data['parameters'] ?? {};
        final maxRiskPoint = data['max_risk_point'] ?? {};
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flood Risk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catchment: ${data['catchment_name'] ?? 'Unknown'}',
                          ),
                          Text(
                            'Rainfall Event: ${data['rainfall_event_id'] ?? 'Unknown'}',
                          ),
                          Text(
                            'Risk Level: ${data['risk_level'] ?? 'Unknown'}',
                          ),
                          Text(
                            'Max Risk: ${(data['max_risk'] != null) ? (data['max_risk'] as num).toStringAsFixed(2) : 'N/A'}',
                          ),
                          if (data['max_risk_time'] != null)
                            Text('Max Risk Time: ${data['max_risk_time']}'),
                          const SizedBox(height: 8),
                          if (parameters.isNotEmpty) ...[
                            Text(
                              'Runoff Coefficient (C): ${parameters['C'] ?? 'N/A'}',
                            ),
                            Text(
                              'Catchment Area: ${parameters['A_km2'] ?? 'N/A'} km²',
                            ),
                            Text(
                              'Pipe Capacity: ${parameters['Qcap_m3s'] ?? 'N/A'} m³/s',
                            ),
                          ],
                          const SizedBox(height: 8),
                          if (maxRiskPoint.isNotEmpty) ...[
                            Text('Max Risk Point:'),
                            Text('  Time: ${maxRiskPoint['t'] ?? 'N/A'}'),
                            Text(
                              '  Rainfall Intensity: ${maxRiskPoint['i'] ?? 'N/A'} mm/hr',
                            ),
                            Text(
                              '  Runoff: ${maxRiskPoint['Qrunoff'] ?? 'N/A'} m³/s',
                            ),
                            Text(
                              '  Capacity Loading Ratio: ${maxRiskPoint['L'] ?? 'N/A'}',
                            ),
                            Text('  Risk Score: ${maxRiskPoint['R'] ?? 'N/A'}'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
