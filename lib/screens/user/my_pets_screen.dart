import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../services/error_helper.dart';
import '../../services/pet_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/user_bottom_nav.dart';
import 'pet_details_screen.dart';
import 'register_pet_screen.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  List<Pet> _pets = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String _filter = 'All';

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
    return _pets.where((p) {
      final matchName = q.isEmpty || p.name.toLowerCase().contains(q);
      final matchType = _filter == 'All' || p.petType == _filter;
      return matchName && matchType;
    }).toList();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    _load(showSpinner: false);
  }

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_pets.isEmpty) {
      return const EmptyState(
        icon: Icons.pets,
        title: 'No pets registered yet',
        message: 'Tap "Register Pet" to add your first pet.',
      );
    }
    final list = _filtered;
    if (list.isEmpty) {
      return const EmptyState(
          icon: Icons.search_off, title: 'No matching pets');
    }
    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth >= 720) {
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 90),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 460,
              mainAxisExtent: 124,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => PetCard(
              pet: list[i],
              onTap: () => _open(PetDetailsScreen(petId: list[i].id)),
            ),
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: list.length,
          itemBuilder: (_, i) => PetCard(
            pet: list[i],
            onTap: () => _open(PetDetailsScreen(petId: list[i].id)),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Pets')),
      bottomNavigationBar:
          UserBottomNav(current: 1, onReturn: () => _load(showSpinner: false)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const RegisterPetScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Register Pet'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by pet name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['All', ...Pet.types]
                  .map((t) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(t),
                          selected: _filter == t,
                          onSelected: (_) => setState(() => _filter = t),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(child: _content()),
        ],
      ),
    );
  }
}