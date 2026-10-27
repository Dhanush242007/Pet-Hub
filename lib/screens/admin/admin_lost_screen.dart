import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../services/admin_service.dart';
import '../../services/error_helper.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/info_row.dart';
import '../../widgets/pet_avatar.dart';

class AdminLostScreen extends StatefulWidget {
  const AdminLostScreen({super.key});

  @override
  State<AdminLostScreen> createState() => _AdminLostScreenState();
}

class _AdminLostScreenState extends State<AdminLostScreen> {
  List<Pet> _pets = [];
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
      final pets = await AdminService().getLostPets();
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = ErrorView(message: _error!, onRetry: _load);
    } else if (_pets.isEmpty) {
      body = const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No lost pets',
        message: 'Pets marked as Found by their owners disappear from this list.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => _load(showSpinner: false),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _pets.length,
          itemBuilder: (_, i) {
            final p = _pets[i];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                          PetAvatar(photoUrl: p.photoUrl, emoji: p.emoji, radius: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(p.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Chip(
                          label: Text('LOST',
                              style: TextStyle(
                                  color: scheme.onErrorContainer,
                                  fontSize: 11)),
                          backgroundColor: scheme.errorContainer,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const Divider(),
                    InfoRow('Pet ID', p.registrationId),
                    InfoRow('Type / Breed',
                        '${p.petType} / ${p.breed ?? '-'}'),
                    InfoRow('Color', p.color),
                    InfoRow('Gender', p.gender),
                    InfoRow('City', p.city),
                    InfoRow('Owner', p.ownerName),
                    InfoRow('Contact', p.ownerPhone),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Pets')),
      body: body,
    );
  }
}