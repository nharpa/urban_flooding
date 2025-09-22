import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/app_google_map.dart';

class HazardMapPage extends StatelessWidget {
  const HazardMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hazard Map')),
      body: const SafeArea(child: AppGoogleMap()),
    );
  }
}
