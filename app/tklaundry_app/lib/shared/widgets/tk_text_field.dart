import 'package:flutter/material.dart';

class TkTextField extends StatelessWidget {
  const TkTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.errorText,
    this.onSubmitted,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            errorText: errorText,
            isDense: true,
          ),
        ),
      ],
    );
  }
}
