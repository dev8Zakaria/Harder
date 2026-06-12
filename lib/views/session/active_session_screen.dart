import 'dart:async';
import 'package:flutter/material.dart';
import '../../controllers/session_controller.dart';
import '../../models/workout_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_card.dart';
import 'session_summary_screen.dart';

class ActiveSessionScreen extends StatefulWidget {
  final WorkoutModel workout;

  const ActiveSessionScreen({super.key, required this.workout});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late final SessionController _sessionController;

  // Timer state
  late DateTime _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Active exercises sets state
  // Map from exercise name to list of SetInfo
  final Map<String, List<SetInfo>> _setsData = {};

  @override
  void initState() {
    super.initState();
    _sessionController = SessionController(widget.workout.userId);
    _startTime = DateTime.now();
    _startTimer();

    // Initialize exercises with 1 default empty set
    for (final exercise in widget.workout.exercises) {
      _setsData[exercise] = [SetInfo(setNumber: 1, reps: '10', weight: '60')];
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final list in _setsData.values) {
      for (final set in list) {
        set.dispose();
      }
    }
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  void _addSet(String exerciseName) {
    setState(() {
      final list = _setsData[exerciseName] ?? [];
      final nextSetNum = list.isEmpty ? 1 : list.length + 1;

      // Default values from last set if exists
      String reps = '10';
      String weight = '60';
      if (list.isNotEmpty) {
        reps = list.last.repsController.text;
        weight = list.last.weightController.text;
      }

      list.add(SetInfo(setNumber: nextSetNum, reps: reps, weight: weight));
      _setsData[exerciseName] = list;
    });
  }

  void _removeSet(String exerciseName, int index) {
    setState(() {
      final list = _setsData[exerciseName] ?? [];
      if (list.length > 1) {
        final removed = list.removeAt(index);
        removed.dispose();
        // Renumber remaining sets
        for (int i = 0; i < list.length; i++) {
          list[i].setNumber = i + 1;
        }
      }
    });
  }

  Future<void> _finishWorkout() async {
    // Collect all completed sets
    int completedSetsCount = 0;
    double totalVolume = 0.0;

    // Check if at least one set is completed
    bool hasAnyCompleted = false;
    for (final exerciseSets in _setsData.values) {
      for (final set in exerciseSets) {
        if (set.isCompleted) {
          hasAnyCompleted = true;
          break;
        }
      }
    }

    if (!hasAnyCompleted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aucun set complété'),
          content: const Text(
            'Veuillez cocher au moins un set comme complété (bouton de validation à droite) pour enregistrer la séance.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('D\'accord'),
            ),
          ],
        ),
      );
      return;
    }

    // Save completed logs to SQLite
    for (final entry in _setsData.entries) {
      final exerciseName = entry.key;
      final sets = entry.value;
      for (final set in sets) {
        if (set.isCompleted) {
          final reps = int.tryParse(set.repsController.text) ?? 0;
          final weight = double.tryParse(set.weightController.text) ?? 0.0;

          await _sessionController.addLog(
            exerciseName: exerciseName,
            setNumber: set.setNumber,
            reps: reps,
            weight: weight,
          );

          completedSetsCount++;
          totalVolume += (reps * weight);
        }
      }
    }

    final durationSeconds = _elapsed.inSeconds;
    final dateStr = DateTime.now().toIso8601String().split('T').first;

    // Save session summary
    await _sessionController.addSession(
      workoutName: widget.workout.name,
      date: dateStr,
      durationSeconds: durationSeconds,
      totalSets: completedSetsCount,
      totalVolume: totalVolume,
    );

    if (!mounted) return;

    // Go to summary screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessionSummaryScreen(
          workoutName: widget.workout.name,
          durationSeconds: durationSeconds,
          totalSets: completedSetsCount,
          totalVolume: totalVolume,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Abandonner l\'entraînement ?'),
                  content: const Text(
                    'Les séries complétées ne seront pas enregistrées.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continuer'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Dialog
                        Navigator.pop(context); // ActiveSessionScreen
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text('Abandonner'),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer Panel
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Text(
                  _formatDuration(_elapsed),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'DURÉE ÉCOULÉE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Exercises List
          Expanded(
            child: widget.workout.exercises.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Aucun exercice dans ce workout. Ajoutez des exercices lors de la création du workout.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.workout.exercises.length,
                    itemBuilder: (context, exIndex) {
                      final exerciseName = widget.workout.exercises[exIndex];
                      final sets = _setsData[exerciseName] ?? [];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exercise Header
                              Text(
                                exerciseName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Column Headers
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      'SÉRIE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'POIDS (KG)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'REPS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 45,
                                    child: Center(
                                      child: Text(
                                        'STATUT',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: AppColors.border,
                                height: 16,
                              ),

                              // Sets list
                              ...List.generate(sets.length, (index) {
                                final set = sets[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    children: [
                                      // Set Number
                                      SizedBox(
                                        width: 30,
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: set.isCompleted
                                              ? AppColors.primary
                                              : AppColors.border,
                                          child: Text(
                                            '${set.setNumber}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: set.isCompleted
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Weight Input
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: TextField(
                                            controller: set.weightController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            enabled: !set.isCompleted,
                                            style: TextStyle(
                                              color: set.isCompleted
                                                  ? AppColors.textSecondary
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              isDense: true,
                                              fillColor: set.isCompleted
                                                  ? AppColors.background
                                                  : AppColors.surface,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Reps Input
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: TextField(
                                            controller: set.repsController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            enabled: !set.isCompleted,
                                            style: TextStyle(
                                              color: set.isCompleted
                                                  ? AppColors.textSecondary
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              isDense: true,
                                              fillColor: set.isCompleted
                                                  ? AppColors.background
                                                  : AppColors.surface,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Complete Checkbox Button
                                      SizedBox(
                                        width: 45,
                                        child: IconButton(
                                          icon: Icon(
                                            set.isCompleted
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: set.isCompleted
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              set.isCompleted =
                                                  !set.isCompleted;
                                            });
                                          },
                                        ),
                                      ),

                                      // Delete Set Button (only visible if editing)
                                      if (!set.isCompleted && sets.length > 1)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.redAccent,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () =>
                                              _removeSet(exerciseName, index),
                                        ),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: 12),

                              // Add set Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _addSet(exerciseName),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Ajouter un set'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Complete Workout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _finishWorkout,
                  icon: const Icon(Icons.done_all, color: Colors.black),
                  label: const Text(
                    'Terminer la séance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
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

class SetInfo {
  int setNumber;
  final TextEditingController repsController;
  final TextEditingController weightController;
  bool isCompleted;

  SetInfo({
    required this.setNumber,
    required String reps,
    required String weight,
    this.isCompleted = false,
  }) : repsController = TextEditingController(text: reps),
       weightController = TextEditingController(text: weight);

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}
