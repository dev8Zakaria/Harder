import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../controllers/body_weight_controller.dart';
import '../../models/body_weight_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class BodyWeightScreen extends StatefulWidget {
  final int userId;

  const BodyWeightScreen({super.key, required this.userId});

  @override
  State<BodyWeightScreen> createState() => _BodyWeightScreenState();
}

class _BodyWeightScreenState extends State<BodyWeightScreen> {
  late final BodyWeightController _controller;
  final _weightCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<BodyWeightModel> _weights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = BodyWeightController(widget.userId);
    _load();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final weights = await _controller.all();
    if (!mounted) return;
    setState(() {
      _weights = weights;
      _loading = false;
    });
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    await _controller.add(double.parse(_weightCtrl.text));
    _weightCtrl.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi du Poids', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Weight input form card
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enregistrer un nouveau poids',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _weightCtrl,
                                label: 'Poids (kg)',
                                icon: Icons.monitor_weight_outlined,
                                keyboardType: TextInputType.number,
                                validator: Validators.positiveNumber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _add,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                              ),
                              child: const Icon(Icons.check, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Chart Card
                if (_weights.length >= 2) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historique de progression',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (value, meta) {
                                      int idx = value.toInt();
                                      if (idx < 0 || idx >= _weights.length) {
                                        return const SizedBox();
                                      }
                                      // Get dates in chronological order (oldest first)
                                      final dateStr = _weights[_weights.length - 1 - idx].date;
                                      final dateParts = dateStr.split('-');
                                      final displayDate = dateParts.length > 2 ? '${dateParts[1]}/${dateParts[2]}' : '';
                                      return Text(
                                        displayDate,
                                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${value.toInt()}kg',
                                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(_weights.length, (i) {
                                    // oldest weights first for X-axis left-to-right
                                    final weightVal = _weights[_weights.length - 1 - i].weight;
                                    return FlSpot(i.toDouble(), weightVal);
                                  }),
                                  isCurved: true,
                                  color: AppColors.primary,
                                  barWidth: 4,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.primary.withOpacity(0.15),
                                  ),
                                ),
                              ],
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
                  'Historique des mesures',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Logs list
                _weights.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'Aucune mesure de poids disponible.\nAjoutez votre poids ci-dessus.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _weights.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final weight = _weights[index];
                          return AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFF384046),
                                child: Icon(Icons.monitor_weight, color: AppColors.primary),
                              ),
                              title: Text(
                                '${weight.weight} kg',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              trailing: Text(
                                weight.date,
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
