import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/building_service.dart';
import '../../../../core/providers/user_provider.dart';

class BuildingSetupScreen extends StatefulWidget {
  const BuildingSetupScreen({super.key});

  @override
  State<BuildingSetupScreen> createState() => _BuildingSetupScreenState();
}

class _BuildingSetupScreenState extends State<BuildingSetupScreen> {
  final _buildingService = BuildingService();
  bool _isLoading = false;

  final _createNameController = TextEditingController();
  final _createAddressController = TextEditingController();
  final _createCityController = TextEditingController();

  final _joinCodeController = TextEditingController();

  Future<void> _createBuilding() async {
    final name = _createNameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final res = await _buildingService.createBuilding(
        name,
        _createAddressController.text.trim(),
        _createCityController.text.trim(),
      );
      if (mounted) {
        await context.read<UserProvider>().tryAutoLogin();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('تم إنشاء العمارة بنجاح'),
            content: SelectableText(
              'شارك كود الدعوة هذا مع جيرانك:\n\n${res["invite_code"]}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الإنشاء')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinBuilding() async {
    final code = _joinCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final res = await _buildingService.joinBuilding(code);
      if (mounted) {
        await context.read<UserProvider>().tryAutoLogin();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'تم الانضمام بنجاح')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('كود غير صالح أو حدث خطأ')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعداد العمارة'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'إنشاء عمارة'),
              Tab(text: 'الانضمام بدعوة'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Create Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _createNameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم العمارة',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _createAddressController,
                          decoration: const InputDecoration(
                            labelText: 'العنوان',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _createCityController,
                          decoration: const InputDecoration(
                            labelText: 'المدينة',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _createBuilding,
                            child: const Text('إنشاء العمارة'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Join Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _joinCodeController,
                          decoration: const InputDecoration(
                            labelText: 'كود الدعوة',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _joinBuilding,
                            child: const Text('الانضمام'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
