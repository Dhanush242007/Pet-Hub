import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../services/error_helper.dart';
import '../../services/pet_service.dart';
import '../../services/photo_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/format.dart';
import '../../widgets/info_row.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/photo_sheet.dart';
import 'medical_screen.dart';
import 'register_pet_screen.dart';
import 'vaccination_screen.dart';

class PetDetailsScreen extends StatefulWidget {
  final String petId;
  const PetDetailsScreen({super.key, required this.petId});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  Pet? _pet;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final pet = await PetService().getPet(widget.petId);
      if (!mounted) return;
      setState(() {
        _pet = pet;
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _changePhoto() async {
    if (_busy || _pet == null) return;
    final pet = _pet!;
    final action = await showPhotoSheet(
      context,
      hasPhoto: pet.photoUrl != null && pet.photoUrl!.isNotEmpty,
    );
    if (action == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final photos = PhotoService();
      if (action.remove) {
        await PetService().updatePet(pet.id, {'photo_url': null});
        await photos.deleteByUrl(pet.photoUrl);
        _snack('Photo removed');
      } else {
        final url = await photos.upload(pet.id, action.file!);
        await PetService().updatePet(pet.id, {'photo_url': url});
        await photos.deleteByUrl(pet.photoUrl);
        _snack('Photo updated');
      }
      await _load(showSpinner: false);
    } catch (e) {
      _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleLost() async {
    if (_busy || _pet == null) return;
    setState(() => _busy = true);
    try {
      final newValue = !_pet!.isLost;
      await PetService().setLost(_pet!.id, newValue);
      await _load(showSpinner: false);
      _snack(newValue
          ? 'Pet marked as LOST'
          : 'Pet marked as FOUND. Welcome home!');
    } catch (e) {
      _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy || _pet == null) return;
    final pet = _pet!;
    final ok = await confirmDialog(
      context,
      title: 'Delete ${pet.name}?',
      message:
          'This also deletes all vaccination and medical records of this pet. This cannot be undone.',
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await PetService().deletePet(pet.id);
      await PhotoService().deleteByUrl(pet.photoUrl);
      if (!mounted) return;
      _snack('Pet deleted');
      Navigator.of(context).pop();
    } catch (e) {
      _snack(friendlyError(e));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _go(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    _load(showSpinner: false);
  }

  Widget _headerCard(Pet pet) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A59), Color(0xFFFFB05C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _busy ? null : _changePhoto,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                PetAvatar(
                    photoUrl: pet.photoUrl, emoji: pet.emoji, radius: 58),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.camera_alt,
                          size: 18, color: scheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(pet.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SelectableText(
              'Pet ID: ${pet.registrationId}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pet = _pet;
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || pet == null
              ? ErrorView(message: _error ?? 'Pet not found', onRetry: _load)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (pet.isLost)
                          Card(
                            color: scheme.errorContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: scheme.onErrorContainer),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'This pet is marked as LOST',
                                      style: TextStyle(
                                          color: scheme.onErrorContainer,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        _headerCard(pet),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                InfoRow('Type', pet.petType),
                                InfoRow('Breed', pet.breed),
                                InfoRow('Age', pet.ageText),
                                InfoRow('Gender', pet.gender),
                                InfoRow('Color', pet.color),
                                InfoRow('Contact', pet.ownerPhone),
                                InfoRow('City', pet.city),
                                InfoRow('Vaccination', pet.vaccinationStatus),
                                InfoRow(
                                    'Status', pet.isLost ? 'LOST' : 'Safe'),
                                InfoRow('Registered', fmtDate(pet.createdAt)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: _busy ? null : _changePhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Change Photo'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonalIcon(
                          onPressed: _busy ? null : _toggleLost,
                          icon: Icon(pet.isLost
                              ? Icons.check_circle_outline
                              : Icons.report_problem_outlined),
                          label: Text(
                              pet.isLost ? 'Mark as Found' : 'Mark as Lost'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => _go(VaccinationScreen(pet: pet)),
                          icon: const Icon(Icons.vaccines),
                          label: const Text('Vaccination Records'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => _go(MedicalScreen(pet: pet)),
                          icon: const Icon(Icons.medical_services_outlined),
                          label: const Text('Medical History'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _go(RegisterPetScreen(pet: pet)),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Pet'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _delete,
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete Pet'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
}