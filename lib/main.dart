import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/theme.dart';
import 'package:urban_flooding/pages/homepage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:urban_flooding/pages/auth/signup.dart';
import 'package:urban_flooding/pages/auth/reset_password.dart';
import 'package:urban_flooding/pages/report/report_issue_page.dart';
import 'package:urban_flooding/pages/report/report_confirmation_page.dart';
import 'package:urban_flooding/widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  // Initialize Firebase (guarded for web/non-configured platforms)
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // If Firebase isn't configured yet, continue without crashing
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Flooding App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // auto switch based on device
      home: const Homepage(),
      routes: {
        '/signup': (_) => const SignUpPage(),
        '/reset-password': (_) => const ResetPasswordPage(),
        '/report': (_) => const AuthGate(child: ReportIssuePage()),
        '/report/confirmation': (_) => const ReportConfirmationPage(),
      },
    );
  }
}
