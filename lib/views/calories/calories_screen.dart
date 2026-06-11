import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../controllers/calories_controller.dart';
import '../../models/calorie_entry_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class CaloriesScreen extends StatefulWidget {
  final int userId;

  const CaloriesScreen({super.key, required this.userId});

  @override
  State<CaloriesScreen> createState() => _CaloriesScreenState();
}

class _CaloriesScreenState extends State<CaloriesScreen> {
  late final CaloriesController _controller;
  final _formKey = GlobalKey<FormState>();
  final _consumedCtrl = TextEditingController(text: '2400');
  final _burnedCtrl = TextEditingController(text: '350');
  final _goalCtrl = TextEditingController(text: '2800');
  List<CalorieEntryModel> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = CaloriesController(widget.userId);
    _load();
  }

  @override
  void dispose() {
    _consumedCtrl.dispose();
    _burnedCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await _controller.all();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    await _controller.add(
      consumed: int.parse(_consumedCtrl.text),
      burned: int.parse(_burnedCtrl.text),
      goal: int.parse(_goalCtrl.text),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calories', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Calorie Form Card
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enregistrer des calories',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _consumedCtrl,
                          label: 'Calories consommées',
                          icon: Icons.restaurant,
                          keyboardType: TextInputType.number,
                          validator: Validators.positiveNumber,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _burnedCtrl,
                                label: 'Brûlées',
                                icon: Icons.local_fire_department_outlined,
                                keyboardType: TextInputType.number,
                                validator: Validators.positiveNumber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                controller: _goalCtrl,
                                label: 'Objectif',
                                icon: Icons.flag_outlined,
                                keyboardType: TextInputType.number,
                                validator: Validators.positiveNumber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _add,
                            icon: const Icon(Icons.check, color: Colors.black),
                            label: const Text(
                              'Enregistrer',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Chart Card
                if (_entries.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calories vs Objectif (Derniers 7 jours)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            const Text('Consommé', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(width: 16),
                            Container(width: 12, height: 12, color: AppColors.blue),
                            const SizedBox(width: 4),
                            const Text('Objectif', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int idx = value.toInt();
                                      final last7 = _entries.take(7).toList();
                                      if (idx < 0 || idx >= last7.length) return const SizedBox();
                                      
                                      // chronological: oldest first on left
                                      final entry = last7[last7.length - 1 - idx];
                                      final dateParts = entry.date.split('-');
                                      final displayDate = dateParts.length > 2 ? '${dateParts[1]}/${dateParts[2]}' : '';
                                      return Text(
                                        displayDate,
                                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(
                                _entries.take(7).length,
                                (i) {
                                  final last7 = _entries.take(7).toList();
                                  final entry = last7[last7.length - 1 - i];
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.consumedCalories.toDouble(),
                                        color: AppColors.primary,
                                        width: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      BarChartRodData(
                                        toY: entry.dailyGoal.toDouble(),
                                        color: AppColors.blue,
                                        width: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Logs list header
                const Text(
                  'Historique des apports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Logs list
                _entries.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'Aucun apport enregistré.\nSaisissez vos données ci-dessus.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFF384046),
                                child: Icon(Icons.local_fire_department, color: AppColors.primary),
                              ),
                              title: Text(
                                '${entry.remaining} kcal restantes',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Consommé : ${entry.consumedCalories} kcal • Brûlé : ${entry.burnedCalories} kcal • Objectif : ${entry.dailyGoal} kcal',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              trailing: Text(
                                entry.date,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }
}
