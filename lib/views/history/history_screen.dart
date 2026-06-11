import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../models/set_log_model.dart';
import '../../widgets/app_card.dart';

class HistoryScreen extends StatefulWidget {
  final int userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final SessionController _controller;
  List<SetLogModel> _logs = [];

  @override
  void initState() {
    super.initState();
    _controller = SessionController(widget.userId);
    _load();
  }

  Future<void> _load() async {
    final logs = await _controller.logs();
    if (!mounted) return;
    setState(() => _logs = logs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _logs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = _logs[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text(log.exerciseName),
                subtitle: Text('Set ${log.setNumber}: ${log.reps} reps x ${log.weight} kg'),
              ),
            );
          },
        ),
      ),
    );
  }
}
