import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../controllers/exercise_controller.dart';
import '../../controllers/workout_controller.dart';
import '../../models/exercise_model.dart';
import '../../models/workout_model.dart';
import '../../utils/exercise_api_config.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import 'package:image_picker/image_picker.dart';

class AddExercisesScreen extends StatefulWidget {
  final WorkoutModel workout;

  const AddExercisesScreen({super.key, required this.workout});

  @override
  State<AddExercisesScreen> createState() => _AddExercisesScreenState();
}

class _AddExercisesScreenState extends State<AddExercisesScreen> {
  late final ExerciseController _exerciseController;
  late final WorkoutController _workoutController;

  List<ExerciseModel> _allExercises = [];
  List<ExerciseModel> _filteredExercises = [];
  List<String> _selectedExerciseNames = [];
  bool _loading = true;
  bool _searching = false;
  Timer? _searchDebounce;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exerciseController = ExerciseController(widget.workout.userId);
    _workoutController = WorkoutController(widget.workout.userId);
    _selectedExerciseNames = List<String>.from(widget.workout.exercises);
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final official = await _exerciseController.officialExercises();
      final custom = await _exerciseController.customExercises();
      if (mounted) {
        setState(() {
          _allExercises = [...custom, ...official];
          _loading = false;
        });
        _filterLocal();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearchChanged() {
    _filterLocal();
    _searchDebounce?.cancel();
    final query = _searchController.text.trim();
    if (query.length < 2) {
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _searchRemote(query);
    });
  }

  Future<void> _searchRemote(String query) async {
    setState(() => _searching = true);
    final apiResults = await _exerciseController.searchOfficialExercises(query);
    final custom = await _exerciseController.customExercises();
    if (!mounted || _searchController.text.trim() != query) {
      return;
    }
    setState(() {
      _allExercises = [...custom, ...apiResults];
      _searching = false;
    });
    _filterLocal();
  }

  void _filterLocal() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = _allExercises;
      } else {
        final List<MapEntry<ExerciseModel, int>> scored = [];
        for (final ex in _allExercises) {
          final name = ex.name.toLowerCase();
          final bodyPart = ex.bodyPart.toLowerCase();
          final target = ex.targetMuscle.toLowerCase();
          final equip = ex.equipment.toLowerCase();

          int score = 0;

          // Priority 1: Exercise Name Matches
          if (name == query) {
            score += 100;
          } else if (name.startsWith(query)) {
            score += 50;
          } else if (name.contains(query)) {
            score += 20;
          }

          // Priority 2: Muscle / Target Matches
          if (target.startsWith(query)) {
            score += 15;
          } else if (target.contains(query)) {
            score += 5;
          }

          // Priority 3: Body Part Matches
          if (bodyPart.startsWith(query)) {
            score += 10;
          } else if (bodyPart.contains(query)) {
            score += 4;
          }

          // Priority 4: Equipment Matches
          if (equip.startsWith(query)) {
            score += 8;
          } else if (equip.contains(query)) {
            score += 3;
          }

          if (score > 0) {
            scored.add(MapEntry(ex, score));
          }
        }

        // Sort by score descending (most relevant first)
        scored.sort((a, b) => b.value.compareTo(a.value));
        _filteredExercises = scored.map((e) => e.key).toList();
      }
    });
  }

  Future<void> _save() async {
    final updatedWorkout = WorkoutModel(
      id: widget.workout.id,
      userId: widget.workout.userId,
      name: widget.workout.name,
      description: widget.workout.description,
      dayName: widget.workout.dayName,
      exercises: _selectedExerciseNames,
    );
    await _workoutController.update(updatedWorkout);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ExerciseForm(
        onSave: (name, body, target, equipment, imagePath) async {
          await _exerciseController.addCustom(
            name: name,
            bodyPart: body,
            targetMuscle: target,
            equipment: equipment,
            imagePath: imagePath,
          );
          await _load();
          _filterLocal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sélectionner exercices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Créer un exercice personnalisé',
            onPressed: _openForm,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Enregistrer la sélection'),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un exercice...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openForm,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Créer un exercice personnalisé'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),

                // Exercise List
                Expanded(
                  child: _filteredExercises.isEmpty
                      ? _EmptySearchState(
                          query: _searchController.text.trim(),
                          onCreate: _openForm,
                          onSuggestion: (value) {
                            _searchController.text = value;
                            _searchController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: value.length),
                                );
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: _filteredExercises.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            final isSelected = _selectedExerciseNames.contains(
                              exercise.name,
                            );

                            return AppCard(
                              child: CheckboxListTile(
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                checkColor: Colors.black,
                                contentPadding: EdgeInsets.zero,
                                value: isSelected,
                                title: Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${exercise.bodyPart} • ${exercise.targetMuscle} • ${exercise.equipment}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                secondary: _ExerciseAvatar(exercise: exercise),
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      if (!_selectedExerciseNames.contains(
                                        exercise.name,
                                      )) {
                                        _selectedExerciseNames.add(
                                          exercise.name,
                                        );
                                      }
                                    } else {
                                      _selectedExerciseNames.remove(
                                        exercise.name,
                                      );
                                    }
                                  });
                                },
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

class _EmptySearchState extends StatelessWidget {
  final String query;
  final VoidCallback onCreate;
  final ValueChanged<String> onSuggestion;

  const _EmptySearchState({
    required this.query,
    required this.onCreate,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = ['bench press', 'squat', 'deadlift', 'pull-up'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          query.isEmpty
              ? 'Recherchez un exercice'
              : 'Aucun résultat pour "$query"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Essayez un nom en anglais ExerciseDB ou créez votre propre exercice.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map(
                (suggestion) => ActionChip(
                  label: Text(suggestion),
                  onPressed: () => onSuggestion(suggestion),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onCreate,
          icon: const Icon(
            Icons.add_photo_alternate_outlined,
            color: Color(0xFF192126),
          ),
          label: const Text('Créer un exercice personnalisé'),
        ),
      ],
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

class _ExerciseForm extends StatefulWidget {
  final Future<void> Function(
    String name,
    String body,
    String target,
    String equipment,
    String? imagePath,
  )
  onSave;

  const _ExerciseForm({required this.onSave});

  @override
  State<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<_ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _bodyPart = 'chest';
  String _targetMuscle = 'pectorals';
  String _equipment = 'barbell';
  String? _imagePath;

  static const _bodyParts = [
    'back',
    'cardio',
    'chest',
    'lower arms',
    'lower legs',
    'neck',
    'shoulders',
    'upper arms',
    'upper legs',
    'waist',
  ];

  static const _targetMuscles = [
    'abs',
    'biceps',
    'calves',
    'delts',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'pectorals',
    'quads',
    'spine',
    'traps',
    'triceps',
  ];

  static const _equipmentOptions = [
    'assisted',
    'band',
    'barbell',
    'body weight',
    'cable',
    'dumbbell',
    'ez barbell',
    'kettlebell',
    'leverage machine',
    'medicine ball',
    'resistance band',
    'smith machine',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _imagePath = image.path);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nouveau Exercice Personnalisé',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameCtrl,
                label: 'Nom',
                icon: Icons.title,
                validator: Validators.requiredText,
              ),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Partie du corps',
                icon: Icons.accessibility_new,
                value: _bodyPart,
                values: _bodyParts,
                onChanged: (value) => setState(() => _bodyPart = value),
              ),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Muscle ciblé',
                icon: Icons.track_changes,
                value: _targetMuscle,
                values: _targetMuscles,
                onChanged: (value) => setState(() => _targetMuscle = value),
              ),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Equipement',
                icon: Icons.fitness_center,
                value: _equipment,
                values: _equipmentOptions,
                onChanged: (value) => setState(() => _equipment = value),
              ),
              const SizedBox(height: 16),
              if (_imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_imagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _imagePath == null
                        ? 'Ajouter une image'
                        : 'Changer l\'image',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    await widget.onSave(
                      _nameCtrl.text.trim(),
                      _bodyPart,
                      _targetMuscle,
                      _equipment,
                      _imagePath,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: const Text(
                    'Créer l\'exercice',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      dropdownColor: Theme.of(context).cardColor,
      items: values
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
