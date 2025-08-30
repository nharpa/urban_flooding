import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.only(bottom: 8.0),
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
                buttonText: "Tips and Tricks",
                onPressed: () {},
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
                onPressed: () {},
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Current Weather Conditions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Current Temperature: 23°C', style: TextStyle(fontSize: 16)),
          Text('Current Conditions: Cloudy', style: TextStyle(fontSize: 16)),
          Text('Current Flood Risk: Moderate', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
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
            const SizedBox(height: 24),
            _buildButtonGrid(context),
            const SizedBox(height: 24),
            _buildWeatherWidget(),
          ],
        ),
      ),
    );
  }
}

class HomePageButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const HomePageButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }
}
