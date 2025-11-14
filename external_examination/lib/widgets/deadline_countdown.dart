import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeadlineCountdown extends StatefulWidget {
  final DateTime deadline;
  const DeadlineCountdown({super.key, required this.deadline});

  @override
  State<DeadlineCountdown> createState() => _DeadlineCountdownState();
}

class _DeadlineCountdownState extends State<DeadlineCountdown> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deadline.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _onTick());
  }

  void _onTick() => setState(() => _remaining = widget.deadline.difference(DateTime.now()));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return const Text('Deadline passed');
    }
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final mins = _remaining.inMinutes % 60;
    return Row(
      children: [
        const Icon(Icons.timer_outlined),
        const SizedBox(width: 8),
        Text('Re-evaluation deadline: ${DateFormat('dd MMM yyyy').format(widget.deadline)}'),
        const SizedBox(width: 8),
        Chip(label: Text('$days d $hours h $mins m')),
      ],
    );
  }
}