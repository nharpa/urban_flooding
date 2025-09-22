import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FloodPreparation extends StatefulWidget {
  const FloodPreparation({super.key});

  @override
  State<FloodPreparation> createState() => _FloodPreparationState();
}

class _FloodPreparationState extends State<FloodPreparation> {
  Map<String, List<String>> eduData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    final String jsonString = await rootBundle.loadString(
      'lib/data/education.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      eduData = jsonMap.map((k, v) => MapEntry(k, List<String>.from(v)));
      _loading = false;
    });
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Divider(thickness: 2),
        const SizedBox(height: 8),
        const Text(
          'Flood Preparation & Survival Guide',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 2),
      ],
    );
  }

  Widget _buildCollapsibleCard(String title, List<String> tips) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips.isNotEmpty
                  ? tips
                        .map(
                          (tip) => Row(
                            children: [
                              const Icon(Icons.circle, size: 8),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        )
                        .toList()
                  : [const Text('None available.')],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flood Preparation')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitle(),
                  _buildCollapsibleCard(
                    'Preparing Your Home',
                    eduData['prepare'] ?? [],
                  ),
                  _buildCollapsibleCard(
                    'Emergency Kit ',
                    eduData['emergencykit'] ?? [],
                  ),
                  _buildCollapsibleCard(
                    'Pets and Livestock',
                    eduData['petsandlivestock'] ?? [],
                  ),
                  _buildCollapsibleCard(
                    'Emergency Help and Contact',
                    eduData['emergencyhelp'] ?? [],
                  ),
                  _buildTitle(),
                  _buildCollapsibleCard(
                    'Advise to Leave/ Leaving',
                    eduData['leave'] ?? [],
                  ),
                  _buildCollapsibleCard(
                    'Unable to Leave',
                    eduData['stuck'] ?? [],
                  ),
                ],
              ),
            ),
    );
  }
}
