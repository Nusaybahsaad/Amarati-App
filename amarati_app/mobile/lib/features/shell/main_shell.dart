import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../dashboard/presentation/pages/tenant_dashboard.dart';
import '../dashboard/presentation/pages/owner_dashboard.dart';
import '../dashboard/presentation/pages/supervisor_dashboard.dart';
import '../dashboard/presentation/pages/provider_dashboard.dart';
import '../maintenance/presentation/pages/maintenance_request_screen.dart';
import '../maintenance/presentation/pages/provider_marketplace_screen.dart';
import '../maintenance/presentation/pages/maintenance_tracker_screen.dart';
import '../payments/presentation/pages/payments_screen.dart';
import '../documents/presentation/pages/documents_screen.dart';
import '../chat/presentation/pages/chat_screen.dart';
import '../profile/presentation/pages/profile_screen.dart';
import '../profile/presentation/pages/provider_profile_screen.dart';

class MainShell extends StatefulWidget {
  final String role; // "tenant", "owner", "supervisor", "provider"

  const MainShell({super.key, this.role = 'tenant'});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  Widget _getDashboard() {
    switch (widget.role) {
      case 'owner':
        return const OwnerDashboard();
      case 'supervisor':
        return const SupervisorDashboard();
      case 'provider':
        return const ProviderDashboard();
      default:
        return const TenantDashboard();
    }
  }

  String _getTitle() {
    switch (widget.role) {
      case 'owner':
        return 'عمارتي - المالك';
      case 'supervisor':
        return 'عمارتي - المشرف';
      default:
        return 'عمارتي';
    }
  }

  List<Widget> get _pages => [
    _getDashboard(),
    const _MaintenanceHub(),
    const PaymentsScreen(),
    const ProfileScreen(),
  ];

  Widget _getProviderShell() {
    // Determine which page to show for the 3 tabs
    // Map index 0->0, index 1->notifications (mocked for now), index 2->provider profile
    final providerPages = [
      const ProviderDashboard(),
      const Scaffold(body: Center(child: Text('الاشعارات'))),
      const ProviderProfileScreen(),
    ];

    // Safety check just in case currentIndex somehow gets > 2
    final safeIndex = _currentIndex > 2 ? 0 : _currentIndex;

    return Scaffold(
      body: providerPages[safeIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.secondary, // Dark brown for active
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'طلبات الصيانة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'الاشعارات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'provider') {
      return _getProviderShell();
    }

    return Scaffold(
      appBar: _currentIndex == 2 || _currentIndex == 3
          ? null // PaymentsScreen and ProfileScreen have their own AppBar
          : AppBar(
              title: Text(_getTitle()),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.folder),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle),
            label: 'الصيانة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'المدفوعات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

/// Hub screen for maintenance — shows list and quick access to forms
class _MaintenanceHub extends StatelessWidget {
  const _MaintenanceHub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصيانة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_circle,
                    label: 'طلب جديد',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MaintenanceRequestScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.store,
                    label: 'سوق الخدمات',
                    color: AppColors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderMarketplaceScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'طلبات الصيانة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Mock active requests
            _RequestCard(
              title: 'تسرب مياه في المطبخ',
              status: 'قيد المراجعة',
              statusColor: AppColors.warning,
              date: '20 فبراير 2026',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaintenanceTrackerScreen(),
                  ),
                );
              },
            ),
            _RequestCard(
              title: 'عطل في المكيف',
              status: 'تم الإسناد',
              statusColor: AppColors.primary,
              date: '18 فبراير 2026',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaintenanceTrackerScreen(),
                  ),
                );
              },
            ),
            _RequestCard(
              title: 'صيانة المصعد (مجتمعية)',
              status: 'تصويت',
              statusColor: AppColors.secondary,
              date: '15 فبراير 2026',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String date;
  final VoidCallback onTap;
  const _RequestCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.build, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
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
