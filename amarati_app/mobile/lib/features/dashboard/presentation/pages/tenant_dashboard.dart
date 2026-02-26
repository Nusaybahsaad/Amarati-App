import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/maintenance_service.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  final _maintenanceService = MaintenanceService();
  List<Map<String, dynamic>> _myRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyRequests();
  }

  Future<void> _fetchMyRequests() async {
    setState(() => _isLoading = true);
    try {
      _myRequests = await _maintenanceService.getMyRequests();
    } catch (e) {
      // user might not be logged in or no requests yet
      _myRequests = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'accepted':
        return 'تم القبول';
      case 'rejected':
        return 'مرفوض';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
      case 'in_progress':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.textSecondary;
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
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.userName.isNotEmpty
        ? userProvider.userName
        : 'المستأجر';

    return RefreshIndicator(
      onRefresh: _fetchMyRequests,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
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
                  const Text(
                    'مرحباً 👋',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'الإجراءات السريعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.build_circle,
                    label: 'طلب صيانة',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.receipt_long,
                    label: 'الفواتير',
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.chat_bubble,
                    label: 'المحادثات',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Maintenance Requests
            const Text(
              'طلبات الصيانة النشطة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_myRequests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'لا توجد طلبات صيانة حالياً',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ..._myRequests.map((req) {
                final status = req['status'] ?? 'pending';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MaintenanceCard(
                    title: '${req['category']} - ${req['description']}',
                    status: _statusLabel(status),
                    statusColor: _statusColor(status),
                    date: _formatDate(req['created_at']?.toString()),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String date;

  const _MaintenanceCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.green75,
          child: Icon(Icons.build, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
