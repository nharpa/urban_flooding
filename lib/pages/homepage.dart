import 'package:flutter/material.dart';
import 'package:urban_flooding/widgets/home_page_button.dart';
import 'package:urban_flooding/pages/floodpreparation.dart';
import 'package:urban_flooding/widgets/weather_card.dart';
import 'package:urban_flooding/pages/weatherforcast.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Widget _buildMapPlaceholder() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Map',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
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
              child: HomePageButton(buttonText: "Hazard Map", onPressed: () {}),
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
                buttonText: "Weather Forecast",
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
              child: HomePageButton(buttonText: "Warnings", onPressed: () {}),
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
            const SizedBox(height: 12),
            _buildButtonGrid(context),
            const SizedBox(height: 24),
            _buildWeatherWidget(),
          ],
        ),
      ),
    );
  }
}
