import 'package:flutter/material.dart';

class HomePageButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const HomePageButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Center(child: Text(buttonText, textAlign: TextAlign.center)),
    );
  }
}
