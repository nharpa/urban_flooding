import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urban_flooding/pages/floodpreparation.dart';
import 'package:urban_flooding/pages/weatherforcast.dart';
import 'package:urban_flooding/pages/warnings.dart';
import 'package:urban_flooding/pages/riskcalculatorpage.dart';
import 'package:urban_flooding/pages/auth/login.dart';
import 'package:urban_flooding/widgets/home_page_button.dart';
import 'package:urban_flooding/widgets/app_google_map.dart';
import 'package:urban_flooding/widgets/weather_card.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Widget _buildMapPlaceholder() {
    // Make the map smaller (e.g., 0.7 aspect ratio)
    return AspectRatio(aspectRatio: 1.4, child: const AppGoogleMap());
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
        const SizedBox(height: 16),
        Row(
          children: [
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
            const SizedBox(width: 16),
            Expanded(
              child: HomePageButton(
                buttonText: "Report an Issue",
                onPressed: () {
                  Navigator.pushNamed(context, '/report');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // New row for Flood Risk button
        Row(
          children: [
            Expanded(
              child: HomePageButton(
                buttonText: "Flood Risk",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RiskCalculatorPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWeatherWidget() {
    return WeatherCard();
  }

  Widget _buildAuthSection(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          final displayName = user.displayName?.trim();
          final nameToShow = (displayName != null && displayName.isNotEmpty)
              ? displayName
              : (user.email ?? 'Signed in');
          return Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  nameToShow,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          );
        }
        // Not signed in: show Log in/Sign up link
        return Align(
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
        );
      },
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
            const SizedBox(height: 10),
            _buildButtonGrid(context),
            const SizedBox(height: 15),
            _buildWeatherWidget(),
            _buildAuthSection(context),
          ],
        ),
      ),
    );
  }
}
