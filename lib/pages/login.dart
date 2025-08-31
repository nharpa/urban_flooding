import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:urban_flooding/widgets/home_page_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: screenHeight / 3,
                child: SvgPicture.asset(
                  'lib/assets/black_swan_logo.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              const Text('Username:', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your username',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Password:', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (val) {
                      setState(() {
                        _rememberMe = val ?? false;
                      });
                    },
                  ),
                  const Text('Remember Login Details:'),
                ],
              ),
              const SizedBox(height: 16),
              HomePageButton(
                buttonText: "Log in",
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () {}, child: const Text('Sign up')),
            ],
          ),
        ),
      ),
    );
  }
}
