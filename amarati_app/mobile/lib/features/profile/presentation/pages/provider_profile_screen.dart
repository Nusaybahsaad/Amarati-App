import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login/role_selection_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userName = userProvider.userName;
    final userEmail = userProvider.user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.edit,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : 'شركة صيانة',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.secondary,
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Menu Options
              _buildMenuOption(
                icon: Icons.language,
                title: 'اللغة',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildMenuOption(
                icon: Icons.badge_outlined,
                title: 'إعدادات الحساب',
              ),
              _buildMenuOption(
                icon: Icons.notifications_none,
                title: 'الاشعارات',
              ),
              _buildMenuOption(
                icon: Icons.help_outline,
                title: 'المساعدة والدعم',
              ),
              _buildMenuOption(icon: Icons.info_outline, title: 'حول'),
              _buildMenuOption(
                icon: Icons.question_answer_outlined,
                title: 'الأسئلة الشائعة',
              ),

              const SizedBox(height: 40),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: OutlinedButton(
                  onPressed: () {
                    context.read<UserProvider>().logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoleSelectionScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.logout, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          trailing: Icon(icon, color: AppColors.textPrimary),
          title: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          leading:
              trailing ??
              const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
          onTap: () {},
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.green75),
      ],
    );
  }
}
