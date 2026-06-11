import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/body_weight_controller.dart';
import '../../controllers/calories_controller.dart';
import '../../controllers/session_controller.dart';
import '../../controllers/workout_controller.dart';
import '../../models/body_weight_model.dart';
import '../../models/workout_session_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  final AuthController authController;

  const DashboardScreen({super.key, required this.authController});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final WorkoutController _workoutController;
  late final SessionController _sessionController;
  late final BodyWeightController _bodyController;
  late final CaloriesController _caloriesController;

  int _workouts = 0;
  int _sets = 0;
  String _weight = '--';
  String _calories = '--';
  List<WorkoutSessionModel> _recentSessions = [];
  List<BodyWeightModel> _weightsList = [];

  @override
  void initState() {
    super.initState();
    final userId = widget.authController.currentUser?.id ?? 0;
    _workoutController = WorkoutController(userId);
    _sessionController = SessionController(userId);
    _bodyController = BodyWeightController(userId);
    _caloriesController = CaloriesController(userId);
    _load();
  }

  Future<void> _load() async {
    final workouts = await _workoutController.all();
    final logs = await _sessionController.logs();
    final weights = await _bodyController.all();
    final calories = await _caloriesController.all();
    final sessions = await _sessionController.sessions();
    if (!mounted) return;
    setState(() {
      _workouts = workouts.length;
      _sets = logs.length;
      _weight = weights.isEmpty ? '--' : '${weights.first.weight.toStringAsFixed(1)} kg';
      _calories = calories.isEmpty ? '--' : '${calories.first.remaining} kcal';
      _recentSessions = sessions.take(3).toList();
      _weightsList = weights;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HARDER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Bonjour, prêt pour la séance ?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Suivi rapide de votre entraînement et de vos objectifs.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            
            const SectionTitle('Statistiques'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                StatCard(label: 'Workouts', value: '$_workouts', icon: Icons.fitness_center),
                StatCard(label: 'Séries loggées', value: '$_sets', icon: Icons.check_circle_outline),
                StatCard(label: 'Dernier poids', value: _weight, icon: Icons.monitor_weight_outlined),
                StatCard(label: 'Calories rest.', value: _calories, icon: Icons.local_fire_department_outlined),
              ],
            ),
            const SizedBox(height: 20),

            // Mini weight chart
            if (_weightsList.length >= 2) ...[
              const SectionTitle('Tendance du poids (Dernières mesures)'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poids actuel : $_weight',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                _weightsList.length > 5 ? 5 : _weightsList.length,
                                (i) {
                                  // Show last 5 chronologically
                                  final last5 = _weightsList.take(5).toList();
                                  final weightVal = last5[last5.length - 1 - i].weight;
                                  return FlSpot(i.toDouble(), weightVal);
                                },
                              ),
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

            const SectionTitle('Séances récentes'),
            _recentSessions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'Aucune séance enregistrée pour le moment.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentSessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final session = _recentSessions[index];
                      final mins = session.durationSeconds ~/ 60;
                      final secs = session.durationSeconds % 60;
                      final durationStr = mins > 0 ? '$mins min' : '$secs sec';
                      return AppCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.workoutName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${session.date} • $durationStr • ${session.totalSets} séries',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Volume',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                Text(
                                  '${session.totalVolume.toStringAsFixed(0)} kg',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
