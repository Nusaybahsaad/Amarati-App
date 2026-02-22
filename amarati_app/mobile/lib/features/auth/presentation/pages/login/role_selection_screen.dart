import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../shell/main_shell.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int _selectedIndex = -1;
  bool _isLoading = false;

  final List<_RoleData> _roles = const [
    _RoleData(
      key: 'owner',
      title: 'مالك',
      description: 'إدارة العمارة، متابعة الصيانة، والإشراف على كل الوحدات',
      icon: Icons.business_rounded,
    ),
    _RoleData(
      key: 'tenant',
      title: 'مستأجر',
      description: 'إرسال طلبات الصيانة، استلم التسهيلات ومتابعة الخدمات',
      icon: Icons.home_rounded,
    ),
    _RoleData(
      key: 'supervisor',
      title: 'مشرف',
      description: 'ترتيب المهام اليومية، متابعة العمال واعتماد الطلبات',
      icon: Icons.engineering_rounded,
    ),
    _RoleData(
      key: 'provider',
      title: 'شركة صيانة',
      description: 'استلم البلاغات، تنفيذ الطلبات، وتحديث حالة الأعمال',
      icon: Icons.build_circle_rounded,
    ),
  ];

  void _handleContinue() async {
    if (_selectedIndex < 0) return;
    final role = _roles[_selectedIndex].key;

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<UserProvider>(context, listen: false);
      await provider.updateRole(role);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainShell(role: role)),
          (route) => false,
        );
      }
    } catch (e) {
      // If API fails, still navigate (offline-friendly)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainShell(role: role)),
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Curved Top Decoration ──────────────────────────────
          SizedBox(
            height: size.height * 0.18,
            width: double.infinity,
            child: ClipPath(
              clipper: _AuthCurveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.almond, AppColors.green200],
                  ),
                ),
              ),
            ),
          ),

          // ── Title ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'اختر نوع حسابك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'حتى نوفّر لك تجربة مخصصة\nتناسب دورك داخل العمارة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Role Cards ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _roles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  role.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  role.description,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.green100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              role.icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Continue Button ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedIndex >= 0 && !_isLoading)
                    ? _handleContinue
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex >= 0
                      ? AppColors.primary
                      : AppColors.green300,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.green300,
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleData {
  final String key;
  final String title;
  final String description;
  final IconData icon;

  const _RoleData({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _AuthCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
