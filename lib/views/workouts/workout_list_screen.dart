import 'package:flutter/material.dart';

import '../../controllers/workout_controller.dart';
import '../../models/workout_model.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../session/active_session_screen.dart';
import 'workout_details_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  final int userId;

  const WorkoutListScreen({super.key, required this.userId});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  late final WorkoutController _controller;
  List<WorkoutModel> _workouts = [];

  @override
  void initState() {
    super.initState();
    _controller = WorkoutController(widget.userId);
    _load();
  }

  Future<void> _load() async {
    final workouts = await _controller.all();
    if (!mounted) return;
    setState(() => _workouts = workouts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Programmes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _workouts.isEmpty
          ? const Center(
              child: Text(
                'Aucun entraînement pour le moment. Cliquez sur + pour en créer un.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _workouts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailsScreen(workout: workout),
                          ),
                        ).then((_) => _load());
                      },
                      title: Text(
                        workout.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      isThreeLine: workout.exercises.isNotEmpty,
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${workout.dayName} • ${workout.description}'
                          '${workout.exercises.isNotEmpty ? '\n${workout.exercises.length} exercices : ${workout.exercises.join(", ")}' : '\n0 exercices (cliquez pour ajouter)'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF384046),
                        child: Icon(Icons.fitness_center, color: Color(0xFFBBF246)),
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: Color(0xFFBBF246), size: 32),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ActiveSessionScreen(workout: workout),
                                ),
                              ).then((_) => _load());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openForm(workout: workout),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await _controller.delete(workout.id!);
                              _load();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _openForm({WorkoutModel? workout}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _WorkoutForm(
        workout: workout,
        onSave: (name, desc, day) async {
          if (workout == null) {
            await _controller.add(name, desc, day, []);
          } else {
            await _controller.update(
              WorkoutModel(
                id: workout.id,
                userId: widget.userId,
                name: name,
                description: desc,
                dayName: day,
                exercises: workout.exercises,
              ),
            );
          }
          await _load();
        },
      ),
    );
  }
}

class _WorkoutForm extends StatefulWidget {
  final WorkoutModel? workout;
  final Future<void> Function(String name, String desc, String day) onSave;

  const _WorkoutForm({required this.onSave, this.workout});

  @override
  State<_WorkoutForm> createState() => _WorkoutFormState();
}

class _WorkoutFormState extends State<_WorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String _day = 'Lundi';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.workout?.name ?? '');
    _descCtrl = TextEditingController(text: widget.workout?.description ?? '');
    _day = widget.workout?.dayName ?? 'Lundi';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.workout == null ? 'Nouveau Workout' : 'Modifier le Workout',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameCtrl,
              label: 'Nom du workout',
              icon: Icons.title,
              validator: Validators.requiredText,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descCtrl,
              label: 'Description',
              icon: Icons.notes,
              validator: Validators.requiredText,
            ),
            const SizedBox(height: 16),
            const Text(
              'Jour d\'entraînement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            DropdownButton<String>(
              value: _day,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
              underline: Container(height: 1, color: Theme.of(context).dividerColor),
              items: const ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
                  .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                  .toList(),
              onChanged: (value) => setState(() => _day = value!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await widget.onSave(_nameCtrl.text.trim(), _descCtrl.text.trim(), _day);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.check, color: Colors.black),
                label: const Text('Enregistrer', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
