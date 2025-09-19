import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Returns the correct icon URL for the current theme (dark/light)
String getWeatherIconUrl(BuildContext context, String baseUrl) {
  final brightness = Theme.of(context).brightness;
  if (brightness == Brightness.dark) {
    return '${baseUrl}_dark.svg';
  } else {
    return '$baseUrl.svg';
  }
}

/// Widget to display a weather SVG icon with loading and error handling
class WeatherIcon extends StatelessWidget {
  final String iconBaseUrl;
  final double size;
  const WeatherIcon({super.key, required this.iconBaseUrl, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final url = getWeatherIconUrl(context, iconBaseUrl);
    return SvgPicture.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => SizedBox(
        width: size,
        height: size,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      // If SVG fails, fallback to a cloud icon
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.wb_cloudy, size: size),
    );
  }
}
