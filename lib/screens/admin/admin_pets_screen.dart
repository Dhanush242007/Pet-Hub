import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../services/admin_service.dart';
import '../../services/error_helper.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/format.dart';
import '../../widgets/info_row.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/pet_avatar.dart';

class AdminPetsScreen extends StatefulWidget {
  const AdminPetsScreen({super.key});

  @override
  State<AdminPetsScreen> createState() => _AdminPetsScreenState();
}

class _AdminPetsScreenState extends State<AdminPetsScreen> {
  List<Pet> _pets = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final pets = await AdminService().getAllPets();
      if (!mounted) return;
      setState(() {
        _pets = pets;
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

  List<Pet> get _filtered {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _pets;
    return _pets.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.registrationId.toLowerCase().contains(q) ||
          (p.ownerName ?? '').toLowerCase().contains(q) ||
          (p.ownerEmail ?? '').toLowerCase().contains(q);
    }).toList();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showDetails(Pet p) async {
    final wantDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
           title: Row(children: [
     PetAvatar(photoUrl: p.photoUrl, emoji: p.emoji, radius: 24),
     const SizedBox(width: 10),
     Expanded(child: Text(p.name)),
   ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoRow('Pet ID', p.registrationId),
              InfoRow('Type', p.petType),
              InfoRow('Breed', p.breed),
              InfoRow('Age', p.ageText),
              InfoRow('Gender', p.gender),
              InfoRow('Color', p.color),
              InfoRow('City', p.city),
              InfoRow('Vaccination', p.vaccinationStatus),
              InfoRow('Status', p.isLost ? 'LOST' : 'Safe'),
              InfoRow('Owner', p.ownerName),
              InfoRow('Owner email', p.ownerEmail),
              InfoRow('Contact', p.ownerPhone),
              InfoRow('Registered', fmtDate(p.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (wantDelete != true || !mounted) return;

    final ok = await confirmDialog(
      context,
      title: 'Delete registration?',
      message:
          'Delete ${p.name} (${p.registrationId}) and all its vaccination and medical records? This cannot be undone.',
    );
    if (!ok) return;
    try {
      await AdminService().deletePet(p.id);
      await _load(showSpinner: false);
      if (!mounted) return;
      _snack('Registration deleted');
    } catch (e) {
      if (!mounted) return;
      _snack(friendlyError(e));
    }
  }

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_pets.isEmpty) {
      return const EmptyState(
          icon: Icons.pets, title: 'No pets registered yet');
    }
    final list = _filtered;
    if (list.isEmpty) {
      return const EmptyState(icon: Icons.search_off, title: 'No matches');
    }
    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: list.length,
        itemBuilder: (_, i) => PetCard(
          pet: list[i],
          extraLine: 'Owner: ${list[i].ownerName ?? '-'}',
          onTap: () => _showDetails(list[i]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Pet Registrations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by pet name, pet ID or owner',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(child: _content()),
        ],
      ),
    );
  }
}