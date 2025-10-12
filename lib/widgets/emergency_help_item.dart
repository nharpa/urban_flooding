import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHelpItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const EmergencyHelpItem({super.key, required this.item});

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildPhoneButton(String phone, String displayText) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: () => _launchPhone(phone),
        child: Row(
          children: [
            Icon(Icons.phone, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 4),
            Text(
              displayText,
              style: TextStyle(
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteButton(String url, String displayText) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: () => _launchWebsite(url),
        child: Row(
          children: [
            Icon(Icons.language, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(Map<String, dynamic> social) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 16),
      child: InkWell(
        onTap: () => _launchWebsite(social['url']),
        child: Row(
          children: [
            Icon(
              social['platform'] == 'Twitter/X' ? Icons.tag : Icons.facebook,
              size: 16,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${social['platform']}: ${social['handle']}',
                style: TextStyle(
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String type = item['type'] ?? 'text';
    final String text = item['text'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main text
          if (text.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Icon(Icons.circle, size: 8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text),
                      // Phone number
                      if (type == 'phone' || type == 'both')
                        _buildPhoneButton(
                          item['phone'] ?? '',
                          item['phone'] ?? '',
                        ),
                      // Website
                      if (type == 'website_social' || type == 'both')
                        if (item['website'] != null)
                          _buildWebsiteButton(
                            item['website'],
                            item['website'].toString().replaceAll(
                              'https://',
                              '',
                            ),
                          ),
                      // Social media links for DFES
                      if (type == 'website_social' && item['social'] != null)
                        ...((item['social'] as List<dynamic>)
                            .map((social) => _buildSocialButton(social))
                            .toList()),
                    ],
                  ),
                ),
              ],
            )
          else
            // For plain text items without clickable elements
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Icon(Icons.circle, size: 8),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(text)),
              ],
            ),
        ],
      ),
    );
  }
}
