import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../shell/main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate API call for OTP request
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to MainShell (default: tenant role)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainShell(role: 'tenant'),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Placeholder
              const Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_rounded,
                        size: 80,
                        color: Color(0xFF4B5320),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'عمارتي',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5320),
                        ),
                      ),
                      Text(
                        'إدارة الأملاك والصيانة بذكاء',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'رقم الجوال',
                        hintText: '05xxxxxxxx',
                        prefixIcon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الجوال';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'تسجيل الدخول / إنشاء حساب',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('تسجيل دخول كشركة صيانة / مشرف'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
