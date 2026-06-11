import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_profile_model.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../home/home_screen.dart';

class AccountInfoScreen extends StatefulWidget {
  final AuthController authController;

  const AccountInfoScreen({super.key, required this.authController});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _profileController = ProfileController();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '23');
  final _heightCtrl = TextEditingController(text: '178');
  final _weightCtrl = TextEditingController(text: '78');
  String _goal = 'Prise de masse';
  String _level = 'Intermédiaire';
  double _sessions = 4;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final userId = widget.authController.currentUser?.id ?? 1;
    await _profileController.save(
      UserProfileModel(
        userId: userId,
        fullName: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        goal: _goal,
        level: _level,
        sessionsPerWeek: _sessions.round(),
        height: double.parse(_heightCtrl.text),
        initialWeight: double.parse(_weightCtrl.text),
      ),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(authController: widget.authController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil initial')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Nom complet',
                      icon: Icons.person_outline,
                      validator: Validators.requiredText,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _ageCtrl,
                      label: 'Age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: Validators.positiveNumber,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _heightCtrl,
                      label: 'Taille en cm',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      validator: Validators.positiveNumber,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _weightCtrl,
                      label: 'Poids initial en kg',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                      validator: Validators.positiveNumber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Objectif'),
                    DropdownButton<String>(
                      value: _goal,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Prise de masse', child: Text('Prise de masse')),
                        DropdownMenuItem(value: 'Perte de poids', child: Text('Perte de poids')),
                        DropdownMenuItem(value: 'Maintien', child: Text('Maintien')),
                      ],
                      onChanged: (value) => setState(() => _goal = value!),
                    ),
                    const SizedBox(height: 10),
                    const Text('Niveau'),
                    DropdownButton<String>(
                      value: _level,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Débutant', child: Text('Débutant')),
                        DropdownMenuItem(value: 'Intermédiaire', child: Text('Intermédiaire')),
                        DropdownMenuItem(value: 'Avancé', child: Text('Avancé')),
                      ],
                      onChanged: (value) => setState(() => _level = value!),
                    ),
                    const SizedBox(height: 10),
                    Text('Séances par semaine: ${_sessions.round()}'),
                    Slider(
                      value: _sessions,
                      min: 2,
                      max: 6,
                      divisions: 4,
                      label: _sessions.round().toString(),
                      onChanged: (value) => setState(() => _sessions = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Valider mon profil',
                icon: Icons.check,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
