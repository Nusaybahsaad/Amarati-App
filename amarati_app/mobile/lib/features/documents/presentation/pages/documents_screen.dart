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
            const SizedBox(height: 24),

            // Empty state
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد مستندات بعد',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اضغط + لرفع مستند جديد',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
