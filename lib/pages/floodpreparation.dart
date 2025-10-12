import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:urban_flooding/widgets/emergency_help_item.dart';

class FloodPreparation extends StatefulWidget {
  const FloodPreparation({super.key});

  @override
  State<FloodPreparation> createState() => _FloodPreparationState();
}

class _FloodPreparationState extends State<FloodPreparation> {
  Map<String, dynamic> eduData = {};
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
      eduData = jsonMap.map((k, v) {
        // Special case for emergencyhelp - keep as dynamic objects
        if (k == 'emergencyhelp') {
          return MapEntry(k, v);
        }
        // For other sections, convert to List<String> as before
        return MapEntry(k, List<String>.from(v));
      });
      _loading = false;
    });
  }

  Widget _buildTitle(String title) {
    return Column(
      children: [
        const Divider(thickness: 2),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Icon(Icons.circle, size: 8),
                              ),
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

  Widget _buildEmergencyHelpCard(String title, List<dynamic> helpItems) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: helpItems.isNotEmpty
                  ? helpItems
                        .map(
                          (item) => EmergencyHelpItem(
                            item: item is Map<String, dynamic>
                                ? item
                                : {'text': item.toString(), 'type': 'text'},
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
                  _buildTitle('Flood Preparation & Survival Guide'),
                  _buildCollapsibleCard(
                    'Preparing Your Home',
                    List<String>.from(eduData['prepare'] ?? []),
                  ),
                  _buildCollapsibleCard(
                    'Emergency Kit ',
                    List<String>.from(eduData['emergencykit'] ?? []),
                  ),
                  _buildCollapsibleCard(
                    'Pets and Livestock',
                    List<String>.from(eduData['petsandlivestock'] ?? []),
                  ),
                  _buildEmergencyHelpCard(
                    'Emergency Help and Contact',
                    eduData['emergencyhelp'] ?? [],
                  ),
                  _buildTitle('During a Flood'),
                  _buildCollapsibleCard(
                    'Advise to Leave/ Leaving',
                    List<String>.from(eduData['leave'] ?? []),
                  ),
                  _buildCollapsibleCard(
                    'Unable to Leave',
                    List<String>.from(eduData['stuck'] ?? []),
                  ),
                ],
              ),
            ),
    );
  }
}
