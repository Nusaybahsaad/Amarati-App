import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications/presentation/pages/notification_preferences_screen.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showAvatar = true;
  bool _buildingOnlyVisibility = false;
  String _language = 'ar';

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'مالك';
      case 'tenant':
        return 'مستأجر';
      case 'supervisor':
        return 'مشرف';
      case 'provider':
        return 'شركة صيانة';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userName = userProvider.userName;
    final userRole = _roleLabel(userProvider.userRole);

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName.isNotEmpty ? userName : 'مستخدم',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              userRole,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Privacy Settings
            _SectionHeader(title: 'إعدادات الخصوصية'),
            SwitchListTile(
              title: const Text('إظهار الصورة الشخصية'),
              subtitle: const Text('إظهار صورتك للآخرين'),
              value: _showAvatar,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _showAvatar = v),
            ),
            SwitchListTile(
              title: const Text('مرئي لسكان المبنى فقط'),
              subtitle: const Text('حصر الظهور على أعضاء المبنى'),
              value: _buildingOnlyVisibility,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _buildingOnlyVisibility = v),
            ),
            const Divider(),

            // Notification Preferences
            _SectionHeader(title: 'تفضيلات الإشعارات'),
            ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: AppColors.textSecondary,
              ),
              title: const Text('إعدادات الإشعارات'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationPreferencesScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // Language
            _SectionHeader(title: 'اللغة'),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _language,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _language = v!),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _language = v!),
            ),
            const Divider(),

            // Account Actions
            ListTile(
              leading: const Icon(Icons.lock, color: AppColors.textSecondary),
              title: const Text('تغيير كلمة المرور'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
