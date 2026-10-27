import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../models/vaccination.dart';
import '../../services/error_helper.dart';
import '../../services/vaccination_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/format.dart';
import '../../widgets/vacc_status_chip.dart';

class VaccinationScreen extends StatefulWidget {
  final Pet pet;
  const VaccinationScreen({super.key, required this.pet});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  List<Vaccination> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final items = await VaccinationService().getForPet(widget.pet.id);
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

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _add() async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _VaccineDialog(),
    );
    if (data == null) return;
    try {
      await VaccinationService().add(widget.pet.id, data);
      await _load(showSpinner: false);
      if (!mounted) return;
      _snack('Vaccination record added');
    } catch (e) {
      if (!mounted) return;
      _snack(friendlyError(e));
    }
  }

  Future<void> _delete(Vaccination v) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete record?',
      message: 'Delete the "${v.vaccineName}" vaccination record?',
    );
    if (!ok) return;
    try {
      await VaccinationService().delete(v.id);
      await _load(showSpinner: false);
      if (!mounted) return;
      _snack('Record deleted');
    } catch (e) {
      if (!mounted) return;
      _snack(friendlyError(e));
    }
  }

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.vaccines,
        title: 'No vaccination records',
        message: 'Tap "Add Vaccine" to create the first record.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final v = _items[i];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.vaccines),
              title: Text(v.vaccineName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(v.status == VaccStatus.planned
                      ? 'Planned for: ${fmtDate(v.dateGiven)}'
                      : 'Given: ${fmtDate(v.dateGiven)}'),
                  Text(v.nextDueDate == null
                      ? 'Next due: not set'
                      : 'Next due: ${fmtDate(v.nextDueDate!)}'),
                  if (v.notes != null && v.notes!.isNotEmpty)
                    Text('Notes: ${v.notes}'),
                  VaccStatusChip(v.status),
                ],
              ),
              trailing: IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(v),
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
      appBar: AppBar(title: Text('${widget.pet.name} • Vaccinations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add Vaccine'),
      ),
      body: _content(),
    );
  }
}

class _VaccineDialog extends StatefulWidget {
  const _VaccineDialog();

  @override
  State<_VaccineDialog> createState() => _VaccineDialogState();
}

class _VaccineDialogState extends State<_VaccineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late DateTime _given;
  DateTime? _next;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _given = DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickGiven() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _given,
      firstDate: DateTime(2000),
            lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (d != null) setState(() => _given = d);
  }

  Future<void> _pickNext() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _next ?? _given.add(const Duration(days: 365)),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _next = d);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_next != null && _next!.isBefore(_given)) {
      setState(() => _dateError = 'Next due date cannot be before the date given');
      return;
    }
    final notes = _notesCtrl.text.trim();
    Navigator.pop(context, <String, dynamic>{
      'vaccine_name': _nameCtrl.text.trim(),
      'date_given': dbDate(_given),
      'next_due_date': _next == null ? null : dbDate(_next!),
      'notes': notes.isEmpty ? null : notes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Vaccination'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Vaccine name *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter the vaccine name'
                    : null,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickGiven,
                icon: const Icon(Icons.event),
                label: Text(_given.isAfter(DateTime.now())
                    ? 'Planned for: ${fmtDate(_given)}'
                    : 'Given: ${fmtDate(_given)}'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickNext,
                icon: const Icon(Icons.event_repeat),
                label: Text(_next == null
                    ? 'Next due date (optional)'
                    : 'Next due: ${fmtDate(_next!)}'),
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_dateError!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12)),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}