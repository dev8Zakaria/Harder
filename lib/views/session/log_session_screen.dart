import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class LogSessionScreen extends StatefulWidget {
  final int userId;

  const LogSessionScreen({super.key, this.userId = 0});

  @override
  State<LogSessionScreen> createState() => _LogSessionScreenState();
}

class _LogSessionScreenState extends State<LogSessionScreen> {
  late final SessionController _controller;
  final _formKey = GlobalKey<FormState>();
  final _exerciseCtrl = TextEditingController(text: 'Développé couché');
  final _setCtrl = TextEditingController(text: '1');
  final _repsCtrl = TextEditingController(text: '10');
  final _weightCtrl = TextEditingController(text: '60');

  @override
  void dispose() {
    _exerciseCtrl.dispose();
    _setCtrl.dispose();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = SessionController(widget.userId);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await _controller.addLog(
      exerciseName: _exerciseCtrl.text.trim(),
      setNumber: int.parse(_setCtrl.text),
      reps: int.parse(_repsCtrl.text),
      weight: double.parse(_weightCtrl.text),
    );
    _setCtrl.text = (int.parse(_setCtrl.text) + 1).toString();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Set enregistré')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logger une séance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _exerciseCtrl,
                  label: 'Exercice',
                  icon: Icons.fitness_center,
                  validator: Validators.requiredText,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _setCtrl,
                  label: 'Set numéro',
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                  validator: Validators.positiveNumber,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _repsCtrl,
                  label: 'Répétitions',
                  icon: Icons.repeat,
                  keyboardType: TextInputType.number,
                  validator: Validators.positiveNumber,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _weightCtrl,
                  label: 'Poids utilisé en kg',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.number,
                  validator: Validators.positiveNumber,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Enregistrer le set'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
