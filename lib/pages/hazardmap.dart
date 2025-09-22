import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/app_google_map.dart';

class HazardMapPage extends StatelessWidget {
  const HazardMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Full-screen map, no app bar; SafeArea to avoid notches
    return const Scaffold(
      body: SafeArea(
        // Full screen Google Map using the reusable widget
        child: AppGoogleMap(),
      ),
    );
  }
}
