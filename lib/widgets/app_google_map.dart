import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppGoogleMap extends StatefulWidget {
  final double initialLat;
  final double initialLon;
  final double initialZoom;
  // Reduce resource usage on Android while debugging rendering issues
  final bool androidLiteMode;
  const AppGoogleMap({
    super.key,
    this.initialLat = -31.95,
    this.initialLon = 115.86,
    this.initialZoom = 11.0,
    this.androidLiteMode = false,
  });

  @override
  State<AppGoogleMap> createState() => _AppGoogleMapState();
}

class _AppGoogleMapState extends State<AppGoogleMap> {
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialLat, widget.initialLon),
          zoom: widget.initialZoom,
        ),
        onMapCreated: (c) => _controller = c,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        liteModeEnabled: widget.androidLiteMode,
      ),
    );
  }
}
