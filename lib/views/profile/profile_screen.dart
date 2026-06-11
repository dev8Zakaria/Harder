import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_profile_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_card.dart';
import '../auth/login_screen.dart';
import '../body/body_weight_screen.dart';
import '../calories/calories_screen.dart';
import '../history/history_screen.dart';
import 'strength_tracking_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AuthController authController;

  const ProfileScreen({super.key, required this.authController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileController = ProfileController();
  UserProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = widget.authController.currentUser?.id ?? 1;
    final profile = await _profileController.getProfile(userId);
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.authController.currentUser?.email ?? 'Utilisateur';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Profile Header Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.person, color: Colors.black, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile?.fullName ?? 'Athlète HARDER',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ProfileStatItem(
                            label: 'Taille',
                            value: _profile != null ? '${_profile!.height.toInt()} cm' : '--',
                          ),
                          _ProfileStatItem(
                            label: 'Poids Init.',
                            value: _profile != null ? '${_profile!.initialWeight.toStringAsFixed(1)} kg' : '--',
                          ),
                          _ProfileStatItem(
                            label: 'Âge',
                            value: _profile != null ? '${_profile!.age} ans' : '--',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Program Details
                      Row(
                        children: [
                          const Icon(Icons.track_changes, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Objectif : ${_profile?.goal ?? 'Non défini'}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.bar_chart, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Niveau : ${_profile?.level ?? 'Non défini'}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // tracking / options header
                const Text(
                  'Mon Suivi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Suivi items list
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ProfileLinkTile(
                        icon: Icons.history,
                        title: 'Historique d\'entraînement',
                        subtitle: 'Visualiser vos séances complétées',
                        onTap: () {
                          final userId = widget.authController.currentUser?.id ?? 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HistoryScreen(userId: userId)),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _ProfileLinkTile(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Suivi de Poids',
                        subtitle: 'Graphiques et logs de vos mesures',
                        onTap: () {
                          final userId = widget.authController.currentUser?.id ?? 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BodyWeightScreen(userId: userId)),
                          ).then((_) => _loadProfile());
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _ProfileLinkTile(
                        icon: Icons.local_fire_department_outlined,
                        title: 'Suivi de Calories',
                        subtitle: 'Calories consommées vs brûlées',
                        onTap: () {
                          final userId = widget.authController.currentUser?.id ?? 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CaloriesScreen(userId: userId)),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _ProfileLinkTile(
                        icon: Icons.trending_up,
                        title: 'Progression de Force',
                        subtitle: 'Graphique de force par exercice',
                        onTap: () {
                          final userId = widget.authController.currentUser?.id ?? 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StrengthTrackingScreen(userId: userId)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Settings header
                const Text(
                  'Paramètres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Settings Card
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                        title: Text('Mode sombre', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Theme sombre verrouille pour respecter le design du projet.'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.authController.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(authController: widget.authController),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ProfileLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF384046),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
