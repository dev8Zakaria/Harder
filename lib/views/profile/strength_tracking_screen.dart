import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/session_controller.dart';
import '../../models/set_log_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_card.dart';

class StrengthTrackingScreen extends StatefulWidget {
  final int userId;

  const StrengthTrackingScreen({super.key, required this.userId});

  @override
  State<StrengthTrackingScreen> createState() => _StrengthTrackingScreenState();
}

class _StrengthTrackingScreenState extends State<StrengthTrackingScreen> {
  late final SessionController _sessionController;
  List<SetLogModel> _allLogs = [];
  List<String> _exercises = [];
  String? _selectedExercise;
  List<SetLogModel> _exerciseLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _sessionController = SessionController(widget.userId);
    _load();
  }

  Future<void> _load() async {
    try {
      final logs = await _sessionController.logs();
      // Extract unique exercises
      final exercises = logs.map((l) => l.exerciseName).toSet().toList();
      exercises.sort();

      if (mounted) {
        setState(() {
          _allLogs = logs;
          _exercises = exercises;
          _selectedExercise = exercises.isNotEmpty ? exercises.first : null;
          _loading = false;
        });
        _updateExerciseLogs();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _updateExerciseLogs() {
    if (_selectedExercise == null) return;
    setState(() {
      // Filter logs for this exercise, reversed so oldest logs are first (X-axis left-to-right)
      _exerciseLogs = _allLogs
          .where((l) => l.exerciseName.toLowerCase() == _selectedExercise!.toLowerCase())
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progression de Force', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Aucune série n\'a été enregistrée.\nTerminez une séance avec des exercices complétés pour voir votre graphique de force.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Sélectionnez un exercice pour voir l\'évolution de vos charges :',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    
                    // Dropdown selector
                    AppCard(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedExercise,
                          isExpanded: true,
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          items: _exercises
                              .map((ex) => DropdownMenuItem(value: ex, child: Text(ex)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedExercise = value;
                            });
                            _updateExerciseLogs();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Chart Card
                    if (_exerciseLogs.isNotEmpty) ...[
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Poids soulevé par série (kg) - $_selectedExercise',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 240,
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
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            'S#${value.toInt() + 1}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 9),
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
                                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: (_exerciseLogs.length - 1).toDouble(),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(_exerciseLogs.length, (i) {
                                        return FlSpot(i.toDouble(), _exerciseLogs[i].weight);
                                      }),
                                      isCurved: true,
                                      color: AppColors.primary,
                                      barWidth: 4,
                                      isStrokeCapRound: true,
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
                      
                      // Recent Log Details
                      const Text(
                        'Détails des séries (plus récents en premier)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _exerciseLogs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          // Display in reverse order (most recent first)
                          final log = _exerciseLogs[_exerciseLogs.length - 1 - index];
                          return AppCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Série ${log.setNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${log.reps} reps x ${log.weight} kg',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
    );
  }
}
