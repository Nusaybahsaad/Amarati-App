import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  const MaintenanceRequestScreen({super.key});

  @override
  State<MaintenanceRequestScreen> createState() =>
      _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  int _currentStep = 0;
  String _requestType = 'personal';
  String _urgency = 'normal';
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedTimeSlot;
  DateTime? _selectedDate;

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
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('إرسال الطلب'),
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
          // Step 1: Type
          Step(
            title: const Text('نوع الطلب'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('صيانة شخصية (خاصة بوحدتي)'),
                  subtitle: const Text('إصلاحات داخل شقتك'),
                  value: 'personal',
                  groupValue: _requestType,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _requestType = v!),
                ),
                RadioListTile<String>(
                  title: const Text('صيانة مجتمعية (مشتركة)'),
                  subtitle: const Text('مصعد، خزان، مناطق مشتركة'),
                  value: 'community',
                  groupValue: _requestType,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _requestType = v!),
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
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان المشكلة',
                    hintText: 'مثال: تسرب مياه',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف تفصيلي',
                    hintText: 'اشرح المشكلة بالتفصيل...',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _urgency,
                  decoration: const InputDecoration(
                    labelText: 'درجة الاستعجال',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                    DropdownMenuItem(value: 'normal', child: Text('عادية')),
                    DropdownMenuItem(value: 'urgent', child: Text('عاجلة')),
                  ],
                  onChanged: (v) => setState(() => _urgency = v!),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('إرفاق صور'),
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
                    _ReviewRow(
                      'النوع:',
                      _requestType == 'personal' ? 'شخصية' : 'مجتمعية',
                    ),
                    _ReviewRow(
                      'العنوان:',
                      _titleController.text.isEmpty
                          ? '-'
                          : _titleController.text,
                    ),
                    _ReviewRow(
                      'الاستعجال:',
                      _urgency == 'urgent'
                          ? 'عاجلة'
                          : _urgency == 'normal'
                          ? 'عادية'
                          : 'منخفضة',
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

  void _submitRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلب الصيانة بنجاح ✅'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
