import 'package:flutter/material.dart';

import '../../models/medical_record.dart';
import '../../models/pet.dart';
import '../../services/error_helper.dart';
import '../../services/medical_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/format.dart';

class MedicalScreen extends StatefulWidget {
  final Pet pet;
  const MedicalScreen({super.key, required this.pet});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  List<MedicalRecord> _items = [];
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
      final items = await MedicalService().getForPet(widget.pet.id);
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
      builder: (_) => const _MedicalDialog(),
    );
    if (data == null) return;
    try {
      await MedicalService().add(widget.pet.id, data);
      await _load(showSpinner: false);
      if (!mounted) return;
      _snack('Medical record added');
    } catch (e) {
      if (!mounted) return;
      _snack(friendlyError(e));
    }
  }

  Future<void> _delete(MedicalRecord r) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete record?',
      message: 'Delete the visit on ${fmtDate(r.visitDate)}?',
    );
    if (!ok) return;
    try {
      await MedicalService().delete(r.id);
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
        icon: Icons.medical_services_outlined,
        title: 'No medical records',
        message: 'Tap "Add Record" to save a vet visit.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final r = _items[i];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              isThreeLine: true,
              leading: const Icon(Icons.medical_services_outlined),
              title: Text(r.condition,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visit: ${fmtDate(r.visitDate)}'),
                  if (r.vetName != null && r.vetName!.isNotEmpty)
                    Text('Vet: ${r.vetName}'),
                  if (r.treatment != null && r.treatment!.isNotEmpty)
                    Text('Treatment: ${r.treatment}'),
                ],
              ),
              trailing: IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(r),
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
      appBar: AppBar(title: Text('${widget.pet.name} • Medical History')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Records are entered by the owner. They are not a diagnosis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(child: _content()),
        ],
      ),
    );
  }
}

class _MedicalDialog extends StatefulWidget {
  const _MedicalDialog();

  @override
  State<_MedicalDialog> createState() => _MedicalDialogState();
}

class _MedicalDialogState extends State<_MedicalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _conditionCtrl = TextEditingController();
  final _vetCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  late DateTime _visit;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _visit = DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _conditionCtrl.dispose();
    _vetCtrl.dispose();
    _treatmentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVisit() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _visit,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _visit = d);
  }

  String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, <String, dynamic>{
      'visit_date': dbDate(_visit),
      'condition': _conditionCtrl.text.trim(),
      'vet_name': _nullIfEmpty(_vetCtrl.text),
      'treatment': _nullIfEmpty(_treatmentCtrl.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medical Record'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: _pickVisit,
                icon: const Icon(Icons.event),
                label: Text('Visit date: ${fmtDate(_visit)}'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    const InputDecoration(labelText: 'Condition / reason *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter the reason for the visit'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vetCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Veterinarian name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _treatmentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Treatment notes'),
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