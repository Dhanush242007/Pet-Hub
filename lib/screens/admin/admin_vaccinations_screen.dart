import 'package:flutter/material.dart';

import '../../models/vaccination.dart';
import '../../services/admin_service.dart';
import '../../services/error_helper.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/format.dart';
import '../../widgets/vacc_status_chip.dart';

class AdminVaccinationsScreen extends StatefulWidget {
  const AdminVaccinationsScreen({super.key});

  @override
  State<AdminVaccinationsScreen> createState() =>
      _AdminVaccinationsScreenState();
}

class _AdminVaccinationsScreenState extends State<AdminVaccinationsScreen> {
  List<Vaccination> _items = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final items = await AdminService().getAllVaccinations();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _loading = false;
      });
    }
  }

  List<Vaccination> get _filtered {
    switch (_filter) {
      case 'Planned':
        return _items.where((v) => v.status == VaccStatus.planned).toList();
      case 'Overdue':
        return _items.where((v) => v.status == VaccStatus.overdue).toList();
      case 'Upcoming':
        return _items.where((v) => v.status == VaccStatus.upcoming).toList();
      default:
        return _items;
    }
  }

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    final list = _filtered;
    if (list.isEmpty) {
      return const EmptyState(
          icon: Icons.vaccines, title: 'No vaccination records found');
    }
    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final v = list[i];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.vaccines),
              title: Text('${v.vaccineName} (${v.petName ?? 'Pet'})',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pet ID: ${v.petRegId ?? '-'}'),
                  Text(v.status == VaccStatus.planned
                      ? 'Planned for: ${fmtDate(v.dateGiven)}'
                      : 'Given: ${fmtDate(v.dateGiven)}'),
                  Text(v.nextDueDate == null
                      ? 'Next due: not set'
                      : 'Next due: ${fmtDate(v.nextDueDate!)}'),
                  VaccStatusChip(v.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination Overview')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'All', label: Text('All')),
                ButtonSegment(value: 'Upcoming', label: Text('Upcoming')),
                ButtonSegment(value: 'Overdue', label: Text('Overdue')),
                ButtonSegment(value: 'Planned', label: Text('Planned')),
              ],
              showSelectedIcon: false,
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
          Expanded(child: _content()),
        ],
      ),
    );
  }
}