import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المدفوعات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'إجمالي المستحق',
                    amount: '٨,٥٠٠ ر.س',
                    color: AppColors.warning,
                    icon: Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'مدفوع هذا الشهر',
                    amount: '٤,٠٠٠ ر.س',
                    color: AppColors.success,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.payment),
                    label: const Text('دفع إلكتروني'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('رفع إيصال'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'سجل المعاملات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _TransactionTile(
              title: 'إيجار - فبراير 2026',
              amount: '٤,٠٠٠ ر.س',
              status: 'مدفوع',
              statusColor: AppColors.success,
              date: '1 فبراير',
              type: 'rent',
            ),
            _TransactionTile(
              title: 'صيانة مكيف',
              amount: '٣٥٠ ر.س',
              status: 'مدفوع',
              statusColor: AppColors.success,
              date: '15 يناير',
              type: 'maintenance',
            ),
            _TransactionTile(
              title: 'إيجار - مارس 2026',
              amount: '٤,٠٠٠ ر.س',
              status: 'مستحق',
              statusColor: AppColors.warning,
              date: '1 مارس',
              type: 'rent',
            ),
            _TransactionTile(
              title: 'مصاريف مشتركة - نظافة',
              amount: '١٥٠ ر.س',
              status: 'مستحق',
              statusColor: AppColors.warning,
              date: '5 مارس',
              type: 'shared',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
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
                fontSize: 18,
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

class _TransactionTile extends StatelessWidget {
  final String title;
  final String amount;
  final String status;
  final Color statusColor;
  final String date;
  final String type;
  const _TransactionTile({
    required this.title,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.type,
  });

  IconData get _icon {
    switch (type) {
      case 'rent':
        return Icons.home;
      case 'maintenance':
        return Icons.build;
      case 'shared':
        return Icons.group;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(_icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(date, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
