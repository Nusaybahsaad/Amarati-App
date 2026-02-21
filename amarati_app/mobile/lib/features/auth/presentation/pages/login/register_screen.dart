import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل دخول كشريك')),
      body: const Center(
        child: Text('Coming Soon: Role Selection (Supervisor/Provider)'),
      ),
    );
  }
}
