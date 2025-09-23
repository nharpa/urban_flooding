import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_flooding/widgets/home_page_button.dart' as uf_widgets;

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];

  Position? _position;
  bool _locating = false;
  bool _submitting = false;
  String? _error;

  static const _reportTypes = <String>[
    'Flooded road',
    'Blocked/Overflowing Drain or Sewer',
    'Broken or Flooded Bridge',
    'Debris Blocking Water Flow',
    'Other',
  ];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission denied';
          _locating = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = pos;
      });
    } catch (e) {
      setState(() => _error = 'Failed to get location: $e');
    } finally {
      setState(() => _locating = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (files.isNotEmpty) {
        setState(() => _photos.addAll(files));
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick images: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      setState(() => _error = 'Please select an issue type');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      // TODO: send to backend; for now just navigate to confirmation
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/report/confirmation');
    } catch (e) {
      setState(() => _error = 'Failed to submit report: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User + Location row
                Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user?.displayName?.trim().isNotEmpty == true
                            ? user!.displayName!
                            : (user?.email ?? 'Anonymous user'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.my_location_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _locating
                          ? const Text('Getting location…')
                          : Text(
                              _position != null
                                  ? 'Lat: ${_position!.latitude.toStringAsFixed(5)}, Lng: ${_position!.longitude.toStringAsFixed(5)}'
                                  : 'Location unavailable',
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    IconButton(
                      tooltip: 'Refresh location',
                      onPressed: _locating ? null : _fetchLocation,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Issue Type
                const Text('What issue are you reporting?'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  items: _reportTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v),
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Please select a type' : null,
                ),

                const SizedBox(height: 16),
                // Description
                const Text('Describe the issue'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Provide details, landmarks, severity, etc.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                // Photos
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Add photos'),
                    ),
                    const SizedBox(width: 12),
                    Text('${_photos.length} selected'),
                  ],
                ),
                const SizedBox(height: 8),
                if (_photos.isNotEmpty)
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final file = File(_photos[i].path);
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                file,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                iconSize: 18,
                                onPressed: () =>
                                    setState(() => _photos.removeAt(i)),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 16),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: uf_widgets.HomePageButton(
                        buttonText: 'Cancel',
                        onPressed: () =>
                            Navigator.popUntil(context, (r) => r.isFirst),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: uf_widgets.HomePageButton(
                        buttonText: _submitting ? 'Submitting…' : 'Submit',
                        onPressed: _submitting ? () {} : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
