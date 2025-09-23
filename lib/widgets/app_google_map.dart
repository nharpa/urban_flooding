import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AppGoogleMap extends StatefulWidget {
  final double initialLat;
  final double initialLon;
  final double initialZoom;
  // Reduce resource usage on Android while debugging rendering issues
  final bool androidLiteMode;
  // Automatically center/zoom to device location when map opens (if permission granted)
  final bool centerOnDevice;
  // Zoom level to use when centering on device
  final double deviceZoom;
  const AppGoogleMap({
    super.key,
    this.initialLat = -31.95,
    this.initialLon = 115.86,
    this.initialZoom = 11.0,
    this.androidLiteMode = false,
    this.centerOnDevice = true,
    this.deviceZoom = 15.0,
  });

  @override
  State<AppGoogleMap> createState() => _AppGoogleMapState();
}

class _AppGoogleMapState extends State<AppGoogleMap> {
  GoogleMapController? _controller;
  bool _attemptedCenter = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _centerOnDeviceIfPossible() async {
    if (_attemptedCenter || !widget.centerOnDevice) return;
    _attemptedCenter = true;
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final c = _controller;
      if (c != null) {
        await c.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(pos.latitude, pos.longitude),
              zoom: widget.deviceZoom,
            ),
          ),
        );
      }
    } catch (_) {
      // Ignore errors and leave map at initial position
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Map fills the available space
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.initialLat, widget.initialLon),
                zoom: widget.initialZoom,
              ),
              onMapCreated: (c) {
                _controller = c;
                // Try to center on device after map is ready
                _centerOnDeviceIfPossible();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              // Keep native controls off to avoid duplicates; we add our own cross-platform buttons
              zoomControlsEnabled: false,
              liteModeEnabled: widget.androidLiteMode,
            ),
          ),
          // Zoom controls overlay (cross-platform)
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: null,
                  onPressed: () =>
                      _controller?.animateCamera(CameraUpdate.zoomIn()),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: null,
                  onPressed: () =>
                      _controller?.animateCamera(CameraUpdate.zoomOut()),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
