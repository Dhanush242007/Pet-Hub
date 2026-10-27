import 'package:flutter/material.dart';

import '../models/vaccination.dart';

class VaccStatusChip extends StatelessWidget {
  final VaccStatus status;
  const VaccStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;
    switch (status) {
      case VaccStatus.planned:
        label = 'Planned';
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        break;
      case VaccStatus.overdue:
        label = 'Overdue';
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      case VaccStatus.upcoming:
        label = 'Due soon';
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        break;
      case VaccStatus.scheduled:
        label = 'Scheduled';
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case VaccStatus.completed:
        label = 'Completed';
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: fg, fontSize: 12)),
      backgroundColor: bg,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}