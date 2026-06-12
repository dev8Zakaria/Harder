import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/exercise_controller.dart';
import '../../models/exercise_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/exercise_api_config.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class ExerciseListScreen extends StatefulWidget {
  final int userId;

  const ExerciseListScreen({super.key, this.userId = 0});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late final ExerciseController _controller;
  List<ExerciseModel> _official = [];
  List<ExerciseModel> _custom = [];

  @override
  void initState() {
    super.initState();
    _controller = ExerciseController(widget.userId);
    _load();
  }

  Future<void> _load() async {
    final official = await _controller.officialExercises();
    final custom = await _controller.customExercises();
    if (!mounted) return;
    setState(() {
      _official = official;
      _custom = custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = [..._custom, ..._official];
    return Scaffold(
      appBar: AppBar(title: const Text('Exercices')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: all.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final exercise = all[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _ExerciseAvatar(exercise: exercise),
                title: Text(exercise.name),
                subtitle: Text(
                  '${exercise.bodyPart} - ${exercise.targetMuscle} - ${exercise.equipment}',
                ),
                trailing: exercise.source == 'custom' && exercise.id != null
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await _controller.deleteCustom(exercise.id!);
                          _load();
                        },
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ExerciseForm(
        onSave: (name, body, target, equipment, imagePath) async {
          await _controller.addCustom(
            name: name,
            bodyPart: body,
            targetMuscle: target,
            equipment: equipment,
            imagePath: imagePath,
          );
          await _load();
        },
      ),
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
    if (image == null) {
      return;
    }
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
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 12),
            if (_imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
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
                  _imagePath == null ? 'Ajouter une image' : 'Changer l image',
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                icon: const Icon(Icons.save_outlined),
                label: const Text('Créer exercice'),
              ),
            ),
          ],
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
          errorBuilder: (_, _, _) {
            return _fallbackIcon(Icons.image_not_supported_outlined);
          },
        ),
      );
    }

    if (exercise.source == 'api' && exercise.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          exercise.imageUrl!,
          headers: ExerciseApiConfig.headers,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return _fallbackIcon(Icons.cloud_outlined);
          },
        ),
      );
    }

    return _fallbackIcon(
      exercise.source == 'custom' ? Icons.person_outline : Icons.cloud_outlined,
    );
  }

  Widget _fallbackIcon(IconData icon) {
    return CircleAvatar(
      backgroundColor: AppColors.primary,
      child: Icon(icon, color: Colors.black),
    );
  }
}
