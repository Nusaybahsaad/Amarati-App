import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}
