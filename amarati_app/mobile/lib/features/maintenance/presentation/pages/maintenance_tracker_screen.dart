import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/maintenance_service.dart';

class MaintenanceTrackerScreen extends StatefulWidget {
  const MaintenanceTrackerScreen({super.key});

  @override
  State<MaintenanceTrackerScreen> createState() =>
      _MaintenanceTrackerScreenState();
}

class _MaintenanceTrackerScreenState extends State<MaintenanceTrackerScreen> {
  final _maintenanceService = MaintenanceService();
  List<Map<String, dynamic>> _myRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      _myRequests = await _maintenanceService.getMyRequests();
    } catch (e) {
      _myRequests = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'تم التقديم';
      case 'accepted':
        return 'تم القبول';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  int _statusIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'in_progress':
        return 2;
      case 'completed':
        return 3;
      case 'rejected':
        return -1;
      default:
        return 0;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final months = [
        '',
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final amPm = dt.hour >= 12 ? 'م' : 'ص';
      return '${dt.day} ${months[dt.month]} - ${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['تم التقديم', 'تم القبول', 'قيد التنفيذ', 'مكتمل'];

    return Scaffold(
      appBar: AppBar(title: const Text('تتبع طلب الصيانة')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myRequests.isEmpty
          ? const Center(
              child: Text(
                'لا توجد طلبات لتتبعها',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _myRequests.length,
                itemBuilder: (context, index) {
                  final req = _myRequests[index];
                  final status = req['status'] ?? 'pending';
                  final currentStep = _statusIndex(status);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${req['category']} - ${req['description']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(req['created_at']?.toString()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (status == 'rejected') ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'تم رفض الطلب',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            ...steps.asMap().entries.map((entry) {
                              final i = entry.key;
                              final stepLabel = entry.value;
                              final isDone = i <= currentStep;
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
                                        padding: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        child: Text(
                                          stepLabel,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isDone
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
