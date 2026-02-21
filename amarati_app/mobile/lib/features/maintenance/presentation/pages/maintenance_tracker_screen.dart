import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MaintenanceTrackerScreen extends StatelessWidget {
  const MaintenanceTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        "status": "submitted",
        "label": "تم التقديم",
        "time": "20 فبراير - 10:30 ص",
        "done": true,
      },
      {
        "status": "under_review",
        "label": "قيد المراجعة",
        "time": "20 فبراير - 11:00 ص",
        "done": true,
      },
      {
        "status": "assigned",
        "label": "تم الإسناد",
        "time": "20 فبراير - 2:00 م",
        "done": true,
      },
      {
        "status": "on_the_way",
        "label": "في الطريق",
        "time": "21 فبراير - 9:00 ص",
        "done": true,
      },
      {
        "status": "arrived",
        "label": "وصل الموقع",
        "time": "21 فبراير - 9:30 ص",
        "done": false,
      },
      {"status": "working", "label": "بدأ العمل", "time": "", "done": false},
      {"status": "completed", "label": "مكتمل", "time": "", "done": false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('تتبع طلب الصيانة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسرب مياه في المطبخ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'شقة 301 - عمارة النور',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'شركة الأمان للصيانة',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'مسار الطلب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Timeline
            ...steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isDone = step["done"] as bool;
              final isLast = i == steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                            child: isDone
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isDone
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step["label"] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDone
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if ((step["time"] as String).isNotEmpty)
                              Text(
                                step["time"] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
