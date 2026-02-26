import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/maintenance_service.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  const MaintenanceRequestScreen({super.key});

  @override
  State<MaintenanceRequestScreen> createState() =>
      _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  int _currentStep = 0;
  String _category = 'كهرباء';
  final _descController = TextEditingController();
  final _unitController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  String? _selectedTimeSlot;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  final _maintenanceService = MaintenanceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب صيانة جديد')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3)
            setState(() => _currentStep++);
          else
            _submitRequest();
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('التالي'),
                  )
                else
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('إرسال الطلب'),
                  ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('السابق'),
                  ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Category
          Step(
            title: const Text('نوع الطلب'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                for (final cat in ['كهرباء', 'سباكة', 'تكييف', 'نظافة', 'أخرى'])
                  RadioListTile<String>(
                    title: Text(cat),
                    value: cat,
                    groupValue: _category,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _category = v!),
                  ),
              ],
            ),
          ),
          // Step 2: Details
          Step(
            title: const Text('تفاصيل المشكلة'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف المشكلة',
                    hintText: 'اشرح المشكلة بالتفصيل...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الشقة',
                    hintText: 'مثال: 38',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الشخص للتواصل',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم هاتف التواصل',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          // Step 3: Time
          Step(
            title: const Text('الوقت المفضل'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'اختر التاريخ',
                  ),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (d != null) setState(() => _selectedDate = d);
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['صباحاً (8-12)', 'ظهراً (12-4)', 'مساءً (4-8)']
                      .map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          onSelected: (v) =>
                              setState(() => _selectedTimeSlot = slot),
                        );
                      })
                      .toList(),
                ),
              ],
            ),
          ),
          // Step 4: Review
          Step(
            title: const Text('مراجعة وإرسال'),
            isActive: _currentStep >= 3,
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReviewRow('النوع:', _category),
                    _ReviewRow(
                      'الوصف:',
                      _descController.text.isEmpty ? '-' : _descController.text,
                    ),
                    _ReviewRow(
                      'رقم الشقة:',
                      _unitController.text.isEmpty ? '-' : _unitController.text,
                    ),
                    _ReviewRow('الوقت:', _selectedTimeSlot ?? 'لم يحدد'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال وصف المشكلة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _maintenanceService.createRequest(
        description: _descController.text.trim(),
        category: _category,
        unitNumber: _unitController.text.trim(),
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب الصيانة بنجاح ✅'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true); // return true to indicate success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إرسال الطلب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _unitController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
