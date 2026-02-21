import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الجواز الرقمي'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.upload_file)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _CategoryChip(label: 'الكل', isSelected: true),
                  SizedBox(width: 8),
                  _CategoryChip(label: 'عقود', isSelected: false),
                  SizedBox(width: 8),
                  _CategoryChip(label: 'فواتير', isSelected: false),
                  SizedBox(width: 8),
                  _CategoryChip(label: 'ضمانات', isSelected: false),
                  SizedBox(width: 8),
                  _CategoryChip(label: 'هوية', isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Expiring Soon Alert
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '2 مستندات تنتهي صلاحيتها قريباً',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const _DocCard(
              title: 'عقد إيجار - شقة 301',
              category: 'عقد',
              date: '1 مارس 2026',
              expiryDate: '1 مارس 2027',
              version: 2,
              icon: Icons.description,
            ),
            const _DocCard(
              title: 'فاتورة كهرباء - يناير',
              category: 'فاتورة',
              date: '15 يناير 2026',
              expiryDate: null,
              version: 1,
              icon: Icons.receipt,
            ),
            const _DocCard(
              title: 'ضمان المكيف',
              category: 'ضمان',
              date: '10 ديسمبر 2025',
              expiryDate: '10 ديسمبر 2026',
              version: 1,
              icon: Icons.verified_user,
            ),
            const _DocCard(
              title: 'هوية المستأجر',
              category: 'هوية',
              date: '5 أكتوبر 2025',
              expiryDate: '5 أكتوبر 2026',
              version: 1,
              icon: Icons.badge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _CategoryChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String? expiryDate;
  final int version;
  final IconData icon;
  const _DocCard({
    required this.title,
    required this.category,
    required this.date,
    this.expiryDate,
    required this.version,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.secondary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$category • v$version', style: const TextStyle(fontSize: 12)),
            if (expiryDate != null)
              Text(
                'ينتهي: $expiryDate',
                style: const TextStyle(fontSize: 11, color: Colors.orange),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('عرض')),
            const PopupMenuItem(
              value: 'version',
              child: Text('رفع نسخة جديدة'),
            ),
            const PopupMenuItem(value: 'share', child: Text('مشاركة')),
          ],
        ),
        isThreeLine: expiryDate != null,
      ),
    );
  }
}
