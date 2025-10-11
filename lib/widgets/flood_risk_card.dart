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
  bool _showAdvanced = false;

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

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterBar(
    String label,
    num value,
    double maxValue,
    Color color, {
    String? unit,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${value.toStringAsFixed(2)}${unit ?? ''}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildRainfallChart(List<dynamic> intensities) {
    if (intensities.isEmpty) return const SizedBox.shrink();

    // Limit to maximum 12 bars to fit on screen without scrolling
    const maxBars = 12;
    final displayIntensities = intensities.length > maxBars
        ? intensities.take(maxBars).toList()
        : intensities;

    final maxIntensity = displayIntensities.cast<num>().reduce(
      (a, b) => a > b ? a : b,
    );

    // Use a minimum scale of 10 to prevent overflow when all values are 0 or very small
    final chartMaxIntensity = maxIntensity > 0 ? maxIntensity : 10;
    const maxBarHeight = 104.0; // Increased by 30% (80 * 1.3)

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(displayIntensities.length, (index) {
        final intensity = displayIntensities[index] as num;
        // Calculate height based on the chart max intensity, with minimum height of 16px for labels
        final minHeight = 16.0; // Minimum height to fit embedded text
        final height = intensity > 0
            ? (intensity / chartMaxIntensity * maxBarHeight).clamp(
                minHeight,
                maxBarHeight,
              )
            : minHeight;
        final isPeak = intensity == maxIntensity && intensity > 0;

        return SizedBox(
          width: 24, // Fixed width to prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 20, // Slightly wider bar for better text visibility
                    height: height,
                    decoration: BoxDecoration(
                      color: intensity > 0
                          ? (isPeak ? Colors.orange[600] : Colors.blue[400])
                          : Colors.grey[300], // Different color for zero values
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                  ),
                  // Embedded text label inside the bar
                  if (intensity > 0 || height >= minHeight)
                    Positioned(
                      child: Text(
                        '${intensity.toInt()}',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: isPeak
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 24,
                child: Text(
                  'H${index + 1}',
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      }),
    );
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

        // Extract additional data from the new structure
        final rainfallIntensities =
            data['rainfall_intensities'] as List<dynamic>? ?? [];

        // Helper functions for visualization
        Color getRiskColor(String? riskLevel) {
          switch (riskLevel?.toLowerCase()) {
            case 'very low':
              return Colors.green;
            case 'low':
              return Colors.lightGreen;
            case 'medium':
              return Colors.orange;
            case 'high':
              return Colors.red;
            case 'very high':
              return Colors.deepPurple;
            default:
              return Colors.grey;
          }
        }

        IconData getRiskIcon(String? riskLevel) {
          switch (riskLevel?.toLowerCase()) {
            case 'very low':
              return Icons.check_circle;
            case 'low':
              return Icons.info;
            case 'medium':
              return Icons.warning;
            case 'high':
              return Icons.error;
            case 'very high':
              return Icons.dangerous;
            default:
              return Icons.help;
          }
        }

        final riskLevel = data['risk_level'] ?? 'Unknown';
        final maxRisk = data['max_risk'] as num?;
        final riskColor = getRiskColor(riskLevel);
        final riskIcon = getRiskIcon(riskLevel);

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [riskColor.withOpacity(0.1), Colors.white],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with risk level and icon
                  Row(
                    children: [
                      Icon(
                        Icons.water_damage,
                        size: 28,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Flood Risk Assessment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Risk Level Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: riskColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(riskIcon, size: 32, color: riskColor),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Risk Level',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              riskLevel,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (maxRisk != null)
                          CircularProgressIndicator(
                            value: (maxRisk.toDouble()).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              riskColor,
                            ),
                            strokeWidth: 6,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Basic Info (Always shown)
                  _buildInfoRow(
                    Icons.location_on,
                    'Catchment',
                    data['catchment_name'] ?? 'Unknown',
                    Colors.blue[600]!,
                  ),

                  _buildInfoRow(
                    Icons.cloud_queue,
                    'Rainfall Event',
                    data['rainfall_event_name'] ??
                        data['rainfall_event_id'] ??
                        'Unknown',
                    Colors.indigo[600]!,
                  ),

                  if (maxRisk != null)
                    _buildInfoRow(
                      Icons.trending_up,
                      'Max Risk Score',
                      '${(maxRisk * 100).toStringAsFixed(1)}%',
                      riskColor,
                    ),

                  // Show Advanced Toggle
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAdvanced = !_showAdvanced;
                        });
                      },
                      icon: Icon(
                        _showAdvanced ? Icons.expand_less : Icons.expand_more,
                      ),
                      label: Text(
                        _showAdvanced ? 'Show Less' : 'Show Advanced Details',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                    ),
                  ),

                  // Advanced Details (Only shown when toggled)
                  if (_showAdvanced) ...[
                    // Rainfall Event Details
                    if (data['total_rainfall_mm'] != null ||
                        data['max_intensity_mmhr'] != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Rainfall Event Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          children: [
                            if (data['total_rainfall_mm'] != null)
                              _buildInfoRow(
                                Icons.opacity,
                                'Total Rainfall',
                                '${data['total_rainfall_mm']} mm',
                                Colors.blue[700]!,
                              ),
                            if (data['max_intensity_mmhr'] != null)
                              _buildInfoRow(
                                Icons.thunderstorm,
                                'Peak Intensity',
                                '${data['max_intensity_mmhr']} mm/hr',
                                Colors.orange[700]!,
                              ),
                            if (data['rainfall_duration_hours'] != null)
                              _buildInfoRow(
                                Icons.schedule,
                                'Duration',
                                '${data['rainfall_duration_hours']} hours',
                                Colors.green[700]!,
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Rainfall Intensity Chart
                    if (rainfallIntensities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Rainfall Intensity Timeline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 156, // Increased by 30% (120 * 1.3)
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildRainfallChart(rainfallIntensities),
                      ),
                    ],

                    // Infrastructure Details
                    const SizedBox(height: 16),
                    Text(
                      'Infrastructure Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (data['runoff_coefficient'] != null)
                            _buildParameterBar(
                              'Runoff Coefficient',
                              data['runoff_coefficient'] as num,
                              1.0,
                              Colors.cyan,
                            ),
                          if (data['catchment_area_km2'] != null)
                            _buildInfoRow(
                              Icons.terrain,
                              'Catchment Area',
                              '${data['catchment_area_km2']} km²',
                              Colors.green[600]!,
                            ),
                          if (data['pipe_capacity_m3s'] != null)
                            _buildInfoRow(
                              Icons.water,
                              'Pipe Capacity',
                              '${data['pipe_capacity_m3s']} m³/s',
                              Colors.blue[600]!,
                            ),
                          if (data['pipe_count'] != null)
                            _buildInfoRow(
                              Icons.linear_scale,
                              'Pipe Count',
                              '${data['pipe_count']} pipes',
                              Colors.purple[600]!,
                            ),
                          if (data['total_pipe_length_m'] != null)
                            _buildInfoRow(
                              Icons.straighten,
                              'Total Length',
                              '${((data['total_pipe_length_m'] as num) / 1000).toStringAsFixed(1)} km',
                              Colors.orange[600]!,
                            ),
                          if (data['max_pipe_diameter_mm'] != null)
                            _buildInfoRow(
                              Icons.circle,
                              'Max Diameter',
                              '${data['max_pipe_diameter_mm']} mm',
                              Colors.indigo[600]!,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
