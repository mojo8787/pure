import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String message;
  
  const ErrorText({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        text: 'Error: ',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: message,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 