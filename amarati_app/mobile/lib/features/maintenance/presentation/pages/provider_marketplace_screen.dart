import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProviderMarketplaceScreen extends StatefulWidget {
  const ProviderMarketplaceScreen({super.key});

  @override
  State<ProviderMarketplaceScreen> createState() =>
      _ProviderMarketplaceScreenState();
}

class _ProviderMarketplaceScreenState extends State<ProviderMarketplaceScreen> {
  String _sortBy = 'rating';

  // Mock provider data
  final List<Map<String, dynamic>> _providers = [
    {
      "company_name": "شركة الأمان للصيانة",
      "specialization": "سباكة",
      "rating": 4.8,
      "total_jobs": 45,
      "response_time": "2.5 ساعة",
      "price_range": "متوسط",
      "is_verified": true,
    },
    {
      "company_name": "مؤسسة النجم للتكييف",
      "specialization": "تكييف",
      "rating": 4.5,
      "total_jobs": 32,
      "response_time": "3 ساعات",
      "price_range": "مرتفع",
      "is_verified": true,
    },
    {
      "company_name": "شركة البناء الحديث",
      "specialization": "كهرباء",
      "rating": 4.2,
      "total_jobs": 28,
      "response_time": "1.5 ساعة",
      "price_range": "منخفض",
      "is_verified": true,
    },
    {
      "company_name": "خدمات الريان",
      "specialization": "نظافة",
      "rating": 4.0,
      "total_jobs": 15,
      "response_time": "4 ساعات",
      "price_range": "منخفض",
      "is_verified": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سوق مزودي الخدمة')),
      body: Column(
        children: [
          // Sort/Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'ترتيب حسب:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('التقييم'),
                  selected: _sortBy == 'rating',
                  onSelected: (_) => setState(() => _sortBy = 'rating'),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _sortBy == 'rating' ? Colors.white : null,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('السرعة'),
                  selected: _sortBy == 'speed',
                  onSelected: (_) => setState(() => _sortBy = 'speed'),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _sortBy == 'speed' ? Colors.white : null,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('السعر'),
                  selected: _sortBy == 'price',
                  onSelected: (_) => setState(() => _sortBy = 'price'),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _sortBy == 'price' ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ),
          // Provider List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final p = _providers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: const Icon(
                                Icons.business,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p["company_name"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (p["is_verified"])
                                        const Icon(
                                          Icons.verified,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                  Text(
                                    p["specialization"],
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _InfoChip(
                              icon: Icons.star,
                              label: '${p["rating"]}',
                              color: Colors.amber,
                            ),
                            _InfoChip(
                              icon: Icons.work,
                              label: '${p["total_jobs"]} مهمة',
                              color: AppColors.primary,
                            ),
                            _InfoChip(
                              icon: Icons.access_time,
                              label: p["response_time"],
                              color: Colors.blue,
                            ),
                            _InfoChip(
                              icon: Icons.attach_money,
                              label: p["price_range"],
                              color: AppColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم اختيار ${p["company_name"]}',
                                  ),
                                ),
                              );
                            },
                            child: const Text('اختيار مزود الخدمة'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
