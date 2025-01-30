import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;

  const CustomSnackBar({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }
}
