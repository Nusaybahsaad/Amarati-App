import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Overview Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, Color(0xFF6B5569)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مالك العقار',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'عمارة النور',
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
                    _StatItem(value: '12', label: 'وحدة'),
                    _StatItem(value: '10', label: 'مأهولة'),
                    _StatItem(value: '2', label: 'شاغرة'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Financial Summary
          const Text(
            'الملخص المالي',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FinanceCard(
                  title: 'الإيجارات المحصلة',
                  amount: '٤٥,٠٠٠ ر.س',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinanceCard(
                  title: 'مستحقات معلقة',
                  amount: '٨,٥٠٠ ر.س',
                  icon: Icons.warning_amber,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'إدارة العقار',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.people,
            title: 'إدارة المستأجرين',
            subtitle: '10 مستأجرين نشطين',
          ),
          _ActionTile(
            icon: Icons.link,
            title: 'إرسال رابط دعوة',
            subtitle: 'دعوة مستأجر جديد',
          ),
          _ActionTile(
            icon: Icons.description,
            title: 'العقود والمستندات',
            subtitle: '3 عقود تنتهي قريباً',
          ),
          _ActionTile(
            icon: Icons.build,
            title: 'طلبات الصيانة',
            subtitle: '5 طلبات نشطة',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _FinanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  const _FinanceCard({
    required this.title,
    required this.amount,
    required this.icon,
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
