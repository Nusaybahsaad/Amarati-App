import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شركة الصيانة',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'شركة الأمان للصيانة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ProviderStat(value: '⭐ 4.8', label: 'التقييم'),
                    _ProviderStat(value: '45', label: 'مهمة مكتملة'),
                    _ProviderStat(value: '3', label: 'مهام نشطة'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Incoming Tasks
          const Text(
            'المهام الواردة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _TaskCard(
            title: 'إصلاح تسرب مياه',
            building: 'عمارة النور - شقة 301',
            urgency: 'عاجل',
            urgencyColor: Colors.red,
            showActions: true,
          ),
          _TaskCard(
            title: 'فحص تكييف مركزي',
            building: 'عمارة الزهور - الدور 2',
            urgency: 'عادي',
            urgencyColor: AppColors.primary,
            showActions: true,
          ),
          const SizedBox(height: 24),

          // Active Tasks
          const Text(
            'المهام النشطة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ActiveTaskCard(
            title: 'صيانة المصعد',
            building: 'عمارة النور',
            status: 'في الطريق',
            statusIcon: Icons.directions_car,
          ),
          const SizedBox(height: 24),

          // Payment Summary
          const Text(
            'المدفوعات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PaymentCard(
                  title: 'مستحقة',
                  amount: '٣,٥٠٠ ر.س',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PaymentCard(
                  title: 'محصلة هذا الشهر',
                  amount: '١٢,٠٠٠ ر.س',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProviderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String building;
  final String urgency;
  final Color urgencyColor;
  final bool showActions;
  const _TaskCard({
    required this.title,
    required this.building,
    required this.urgency,
    required this.urgencyColor,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    urgency,
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              building,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('رفض')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () {}, child: const Text('قبول')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final String title;
  final String building;
  final String status;
  final IconData statusIcon;
  const _ActiveTaskCard({
    required this.title,
    required this.building,
    required this.status,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Icon(statusIcon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(building, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  const _PaymentCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
