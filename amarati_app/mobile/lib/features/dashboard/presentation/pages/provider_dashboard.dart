import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/maintenance_service.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _maintenanceService = MaintenanceService();

  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _inProgressRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allRequests = await _maintenanceService.getRequests();

      _pendingRequests = allRequests
          .where((r) => r['status'] == 'pending')
          .toList();
      _inProgressRequests = allRequests
          .where(
            (r) => r['status'] == 'accepted' || r['status'] == 'in_progress',
          )
          .toList();
      _completedRequests = allRequests
          .where((r) => r['status'] == 'completed' || r['status'] == 'rejected')
          .toList();
    } catch (e) {
      _error = 'فشل في تحميل الطلبات';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      await _maintenanceService.updateStatus(
        requestId: requestId,
        status: status,
      );
      await _fetchRequests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحديث الحالة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserProvider>().userName;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'شركة صيانة العمارة',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      if (userName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom TabBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.grey75.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textPrimary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  Tab(text: 'قيد الانتظار (${_pendingRequests.length})'),
                  Tab(text: 'جارية (${_inProgressRequests.length})'),
                  Tab(text: 'مكتملة (${_completedRequests.length})'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tab Views
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchRequests,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestList(_pendingRequests, showActions: true),
                      _buildRequestList(_inProgressRequests),
                      _buildRequestList(_completedRequests),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(
    List<Map<String, dynamic>> requests, {
    bool showActions = false,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'لا توجد طلبات هنا',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _fetchRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final isFirst = index == 0;
          return _RequestCard(
            request: req,
            expanded: isFirst && showActions,
            showActions: showActions,
            onAccept: () => _updateRequestStatus(req['request_id'], 'accepted'),
            onReject: () => _updateRequestStatus(req['request_id'], 'rejected'),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final bool expanded;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _RequestCard({
    required this.request,
    this.expanded = false,
    this.showActions = false,
    this.onAccept,
    this.onReject,
  });

  String _formatTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final amPm = dt.hour >= 12 ? 'م' : 'ص';
      return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return '';
    }
  }

  String _shortId(String id) {
    // Show last 4 chars as a readable request number
    return id.length > 4 ? id.substring(id.length - 4).toUpperCase() : id;
  }

  @override
  Widget build(BuildContext context) {
    final id = request['request_id'] ?? '';
    final category = request['category'] ?? '';
    final description = request['description'] ?? '';
    final unitNumber = request['unit_number'] ?? '';
    final contactName = request['contact_name'] ?? '';
    final contactPhone = request['contact_phone'] ?? '';
    final createdAt = request['created_at']?.toString();

    // Collapsed design
    if (!expanded) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.grey75.withValues(alpha: 0.3),
          border: Border.all(color: AppColors.secondary, width: 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond, size: 12, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'طلب رقم: ${_shortId(id)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'نوع الطلب: $category',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Expanded design
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.grey75.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.secondary, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.diamond, size: 12, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'طلب رقم: ${_shortId(id)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'نوع الطلب: $category',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'الوصف: $description',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (unitNumber.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'رقم الشقة: $unitNumber',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'وقت الساعة: ${_formatTime(createdAt)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (contactName.isNotEmpty || contactPhone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'معلومات التواصل: $contactPhone - $contactName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          if (showActions) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'قبول',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey75,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'رفض',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Note Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: 'إرسال ملاحظة',
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
