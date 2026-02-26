import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/maintenance_service.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final _maintenanceService = MaintenanceService();
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _inProgressRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final all = await _maintenanceService.getRequests();
      _pendingRequests = all.where((r) => r['status'] == 'pending').toList();
      _inProgressRequests = all
          .where((r) =>
              r['status'] == 'accepted' || r['status'] == 'in_progress')
          .toList();
      _completedRequests = all
          .where((r) =>
              r['status'] == 'completed' || r['status'] == 'rejected')
          .toList();
    } catch (e) {
      // Silently handle error - counts will show 0
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(String requestId, String status) async {
    try {
      await _maintenanceService.updateStatus(
        requestId: requestId,
        status: status,
      );
      await _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحديث الحالة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserProvider>().userName;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supervisor Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.green400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.isNotEmpty ? userName : 'المشرف',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'لوحة المراقبة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatBadge(
                              value: '${_pendingRequests.length}',
                              label: 'طلبات جديدة',
                              color: Colors.orange,
                            ),
                            _StatBadge(
                              value: '${_inProgressRequests.length}',
                              label: 'قيد التنفيذ',
                              color: Colors.blue,
                            ),
                            _StatBadge(
                              value: '${_completedRequests.length}',
                              label: 'مكتملة',
                              color: Colors.green,
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pending Approvals
            const Text(
              'بانتظار الموافقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_pendingRequests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'لا توجد طلبات بانتظار الموافقة',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ..._pendingRequests.map((req) => _ApprovalCard(
                    title: '${req['category']} - ${req['description']}',
                    submittedBy: req['contact_name'] ?? '',
                    unitNumber: req['unit_number'] ?? '',
                    onApprove: () =>
                        _updateStatus(req['request_id'], 'accepted'),
                    onReject: () =>
                        _updateStatus(req['request_id'], 'rejected'),
                  )),

            const SizedBox(height: 24),

            // Reports Section
            const Text(
              'التقارير',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ReportCard(
                    icon: Icons.assessment,
                    title: 'تقرير الصيانة',
                    subtitle: 'الشهري',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportCard(
                    icon: Icons.account_balance_wallet,
                    title: 'التقرير المالي',
                    subtitle: 'المصروفات المشتركة',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBadge({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final String title;
  final String submittedBy;
  final String unitNumber;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ApprovalCard({
    required this.title,
    required this.submittedBy,
    required this.unitNumber,
    required this.onApprove,
    required this.onReject,
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            if (submittedBy.isNotEmpty)
              Text(
                'مقدم من: $submittedBy${unitNumber.isNotEmpty ? ' - شقة $unitNumber' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onReject,
                  child: const Text(
                    'رفض',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onApprove,
                  child: const Text('موافقة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
