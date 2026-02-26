import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProviderMarketplaceScreen extends StatelessWidget {
  const ProviderMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سوق شركات الصيانة')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_outlined,
                size: 72,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد شركات مسجلة بعد',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ستظهر شركات الصيانة المسجلة هنا عند توفرها',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
