import 'package:flutter/material.dart';

class WarningsPage extends StatelessWidget {
  const WarningsPage({super.key});

  Widget _buildTitle() {
    return Column(
      children: [
        const Divider(thickness: 2),
        const SizedBox(height: 8),
        const Text(
          'Current Flood Warnings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'Advice/Watch and Act/Emergency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.redAccent,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 2),
      ],
    );
  }

  List<String> getSocialMediaPosts() {
    // Replace with API call later
    return [
      'Flood warning issued for Riverdale. Stay alert and follow local advice.',
      'Heavy rainfall expected tonight. Watch and act as needed.',
      'Emergency services are on standby. Check official channels for updates.',
    ];
  }

  Widget _buildSocialMediaCards() {
    final posts = getSocialMediaPosts();
    return Column(
      children: posts
          .map(
            (post) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(post, style: const TextStyle(fontSize: 16)),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Further Help and Contacts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 12),
          height: 2,
          color: Colors.blueGrey,
        ),
        const Text('SES: 132 500'),
        const Text('Emergency: 000'),
        const Text('Local Council: 1234 5678'),
        const Text('Flood Info Line: 1800 123 456'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flood Warnings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            _buildSocialMediaCards(),
            _buildContactsSection(),
          ],
        ),
      ),
    );
  }
}
