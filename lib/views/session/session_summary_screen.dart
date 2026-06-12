import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class SessionSummaryScreen extends StatelessWidget {
  final String workoutName;
  final int durationSeconds;
  final int totalSets;
  final double totalVolume;

  const SessionSummaryScreen({
    super.key,
    required this.workoutName,
    required this.durationSeconds,
    required this.totalSets,
    required this.totalVolume,
  });

  String _formatDuration(int totalSecs) {
    final hours = totalSecs ~/ 3600;
    final minutes = (totalSecs % 3600) ~/ 60;
    final seconds = totalSecs % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon / Celebration
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.black,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Félicitations !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous avez terminé votre entraînement :',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                workoutName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 36),

              // Stats Card
              AppCard(
                child: Column(
                  children: [
                    const Text(
                      'RÉSUMÉ DE LA SÉANCE',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Durée',
                          value: _formatDuration(durationSeconds),
                          icon: Icons.timer_outlined,
                        ),
                        _StatItem(
                          label: 'Séries',
                          value: '$totalSets',
                          icon: Icons.check_circle_outline,
                        ),
                        _StatItem(
                          label: 'Volume',
                          value: '${totalVolume.toStringAsFixed(0)} kg',
                          icon: Icons.fitness_center_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Return Home Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Retour à l\'accueil',
                  icon: Icons.home_outlined,
                  onPressed: () {
                    // Navigate back to the main app layout
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
