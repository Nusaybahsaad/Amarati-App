import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final _service = NotificationService();
  bool _isLoading = true;
  bool _isSaving = false;

  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _inAppEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await _service.getPreferences();
      if (mounted) {
        setState(() {
          _pushEnabled = prefs['push'] ?? true;
          _emailEnabled = prefs['email'] ?? true;
          _inAppEnabled = prefs['in_app'] ?? true;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePrefs() async {
    setState(() => _isSaving = true);
    try {
      await _service.updatePreferences({
        'push': _pushEnabled,
        'email': _emailEnabled,
        'in_app': _inAppEnabled,
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحفظ')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الإشعارات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'تحكم في كيفية تنبيهك بالأحداث الهامة',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('إشعارات داخل التطبيق'),
                  subtitle: const Text('تلقي التنبيهات أثناء استخدامك للتطبيق'),
                  value: _inAppEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _inAppEnabled = val),
                ),
                SwitchListTile(
                  title: const Text('إشعارات الدفع (Push)'),
                  subtitle: const Text('تلقي تنبيهات على هاتفك الذكي'),
                  value: _pushEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _pushEnabled = val),
                ),
                SwitchListTile(
                  title: const Text('رسائل البريد الإلكتروني'),
                  subtitle: const Text('استلام تفاصيل هامة على بريدك'),
                  value: _emailEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _emailEnabled = val),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isSaving ? null : _savePrefs,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('حفظ التغييرات'),
                  ),
                ),
              ],
            ),
    );
  }
}
