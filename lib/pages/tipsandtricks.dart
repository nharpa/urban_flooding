import 'package:flutter/material.dart';

class TipsAndTricksPage extends StatelessWidget {
  const TipsAndTricksPage({super.key});

  Widget _buildTitle() {
    return Column(
      children: [
        const Divider(thickness: 2),
        const SizedBox(height: 8),
        const Text(
          'Flood Preperation & Survival Guide',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 2),
      ],
    );
  }

  Widget _buildCollapsibleCard(String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                5,
                (index) => Row(
                  children: const [
                    Icon(Icons.circle, size: 8),
                    SizedBox(width: 8),
                    Text('Placeholder tip goes here.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flood Preperation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            _buildCollapsibleCard('Preparing Your Home'),
            _buildCollapsibleCard('Emergency Kit Preperation'),
            _buildCollapsibleCard('Pets and Livestock'),
            _buildCollapsibleCard('Emergency Help and Contact'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
