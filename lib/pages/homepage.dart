import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/home_page_button.dart';
import 'package:urban_flooding/pages/floodpreparation.dart';
import 'package:urban_flooding/widgets/weather_card.dart';
import 'package:urban_flooding/pages/weatherforcast.dart';
import 'package:urban_flooding/pages/hazardmap.dart';
import 'package:urban_flooding/pages/warnings.dart';
import 'package:urban_flooding/pages/login.dart';
import 'package:urban_flooding/widgets/app_google_map.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Widget _buildMapPlaceholder() {
    return AspectRatio(aspectRatio: 1, child: const AppGoogleMap());
  }

  Widget _buildButtonGrid(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "Information Portal",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: HomePageButton(
                buttonText: "Hazard Map",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HazardMapPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16), // spacing between buttons
            Expanded(
              child: HomePageButton(
                buttonText: "Flood Preparation",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FloodPreparation(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // spacing between rows
        Row(
          children: [
            Expanded(
              child: HomePageButton(
                buttonText: "Weather",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeatherForecastPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HomePageButton(
                buttonText: "Warnings",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WarningsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherWidget() {
    return WeatherCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Urban Flooding App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMapPlaceholder(),
            const SizedBox(height: 10),
            _buildButtonGrid(context),
            const SizedBox(height: 15),
            _buildWeatherWidget(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Log in/Sign up',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
