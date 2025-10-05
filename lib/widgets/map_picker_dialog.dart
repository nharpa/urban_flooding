import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerDialog extends StatefulWidget {
  final double initialLat;
  final double initialLon;
  final double initialZoom;
  const MapPickerDialog({
    super.key,
    this.initialLat = -31.95,
    this.initialLon = 115.86,
    this.initialZoom = 11.0,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  LatLng? _selectedLatLng;
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Location'),
      content: SizedBox(
        width: 350,
        height: 350,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.initialLat, widget.initialLon),
            zoom: widget.initialZoom,
          ),
          onMapCreated: (c) => _controller = c,
          onTap: (latLng) {
            setState(() {
              _selectedLatLng = latLng;
            });
          },
          markers: _selectedLatLng == null
              ? {}
              : {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: _selectedLatLng!,
                  ),
                },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedLatLng == null
              ? null
              : () async {
                  Navigator.of(context).pop(
                    Position(
                      latitude: _selectedLatLng!.latitude,
                      longitude: _selectedLatLng!.longitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    ),
                  );
                },
          child: const Text('Select'),
        ),
      ],
    );
  }
}
