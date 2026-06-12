import 'dart:io';
import 'package:flutter/material.dart';

import '../../controllers/exercise_controller.dart';
import '../../controllers/workout_controller.dart';
import '../../models/exercise_model.dart';
import '../../models/workout_model.dart';
import '../../utils/exercise_api_config.dart';
import '../../widgets/app_card.dart';
import '../session/active_session_screen.dart';
import 'add_exercises_screen.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  late final ExerciseController _exerciseController;
  late final WorkoutController _workoutController;
  late WorkoutModel _workout;
  List<ExerciseModel> _allExercises = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    _exerciseController = ExerciseController(_workout.userId);
    _workoutController = WorkoutController(_workout.userId);
    _load();
  }

  Future<void> _load() async {
    try {
      final workouts = await _workoutController.all();
      final updatedWorkout = workouts.firstWhere(
        (w) => w.id == _workout.id,
        orElse: () => _workout,
      );

      final official = await _exerciseController.officialExercises();
      final custom = await _exerciseController.customExercises();

      if (mounted) {
        setState(() {
          _workout = updatedWorkout;
          _allExercises = [...custom, ...official];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  ExerciseModel? _findExercise(String name) {
    try {
      return _allExercises.firstWhere(
        (e) => e.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _removeExercise(String exerciseName) async {
    final updatedList = List<String>.from(_workout.exercises)
      ..remove(exerciseName);
    final updatedWorkout = WorkoutModel(
      id: _workout.id,
      userId: _workout.userId,
      name: _workout.name,
      description: _workout.description,
      dayName: _workout.dayName,
      exercises: updatedList,
    );
    await _workoutController.update(updatedWorkout);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _workout.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActiveSessionScreen(workout: _workout),
                ),
              ).then((_) => _load());
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _workout.dayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _workout.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Exercices de la séance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddExercisesScreen(workout: _workout),
                          ),
                        ).then((_) => _load());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Exercises List
                _workout.exercises.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'Aucun exercice associé à cette séance.\nCliquez sur "Ajouter" pour commencer.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _workout.exercises.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final exName = _workout.exercises[index];
                          final exercise = _findExercise(exName);

                          return AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: exercise != null
                                  ? _ExerciseAvatar(exercise: exercise)
                                  : const CircleAvatar(
                                      child: Icon(Icons.fitness_center),
                                    ),
                              title: Text(
                                exName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: exercise != null
                                  ? Text(
                                      '${exercise.bodyPart} • ${exercise.targetMuscle} • ${exercise.equipment}',
                                    )
                                  : const Text('Exercice'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _removeExercise(exName),
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

class _ExerciseAvatar extends StatelessWidget {
  final ExerciseModel exercise;

  const _ExerciseAvatar({required this.exercise});

  @override
  Widget build(BuildContext context) {
    if (exercise.source == 'custom' && exercise.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(exercise.imagePath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              _fallbackIcon(Icons.image_not_supported_outlined),
        ),
      );
    }

    if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          exercise.imageUrl!,
          headers: ExerciseApiConfig.headers,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackIcon(Icons.cloud_outlined),
        ),
      );
    }

    return _fallbackIcon(
      exercise.source == 'custom' ? Icons.person_outline : Icons.cloud_outlined,
    );
  }

  Widget _fallbackIcon(IconData icon) {
    return CircleAvatar(
      backgroundColor: const Color(0xFF384046),
      child: Icon(icon, color: const Color(0xFFBBF246)),
    );
  }
}
