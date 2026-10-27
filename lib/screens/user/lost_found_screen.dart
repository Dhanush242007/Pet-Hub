import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../services/error_helper.dart';
import '../../services/pet_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/user_bottom_nav.dart';
import 'pet_details_screen.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  List<Pet> _lost = [];
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
      final pets = await PetService().getMyPets();
      if (!mounted) return;
      setState(() {
        _lost = pets.where((p) => p.isLost).toList();
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

  Future<void> _openPet(Pet p) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PetDetailsScreen(petId: p.id)));
    if (!mounted) return;
    _load(showSpinner: false);
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_lost.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        emoji: '🏡',
        title: 'All your pets are safe',
        message:
            'If a pet goes missing, open its profile and tap "Mark as Lost".',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        itemCount: _lost.length,
        itemBuilder: (_, i) =>
            PetCard(pet: _lost[i], onTap: () => _openPet(_lost[i])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      bottomNavigationBar:
          UserBottomNav(current: 3, onReturn: () => _load(showSpinner: false)),
      body: _body(),
    );
  }
}