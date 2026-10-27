import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../models/profile.dart';
import '../../models/vaccination.dart';
import '../../services/error_helper.dart';
import '../../services/pet_service.dart';
import '../../services/vaccination_service.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/format.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/vacc_status_chip.dart';
import '../auth/role_router.dart';
import 'my_pets_screen.dart';
import '../../widgets/user_bottom_nav.dart';
import 'pet_details_screen.dart';
import 'register_pet_screen.dart';

class UserDashboard extends StatefulWidget {
  final Profile profile;
  const UserDashboard({super.key, required this.profile});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool _loading = true;
  String? _error;
  List<Pet> _pets = [];
  List<Vaccination> _reminders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final pets = await PetService().getMyPets();
      final reminders = await VaccinationService().getReminders();
      if (!mounted) return;
      setState(() {
        _pets = pets;
        _reminders = reminders;
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

  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    _load(showSpinner: false);
  }

  Widget _sectionTitle(String text, [String? sub]) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          if (sub != null) Text(sub, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);

    final lostCount = _pets.where((p) => p.isLost).length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: RefreshIndicator(
          onRefresh: () => _load(showSpinner: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                        icon: Icons.pets,
                        value: '${_pets.length}',
                        label: 'My pets',
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                        icon: Icons.vaccines,
                        value: '${_reminders.length}',
                        label: 'Vaccines due',
                        color: Colors.green),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                        icon: Icons.report_problem,
                        value: '$lostCount',
                        label: 'Lost',
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ActionTile(
                      icon: Icons.add_circle,
                      label: 'Register Pet',
                      color: Colors.deepOrange,
                      onTap: () => _open(const RegisterPetScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionTile(
                      icon: Icons.favorite,
                      label: 'My Pets',
                      color: Colors.pink,
                      onTap: () => _open(const MyPetsScreen()),
                    ),
                  ),
                ],
              ),
              if (_pets.isNotEmpty) ...[
                _sectionTitle('Your pets'),
                SizedBox(
                  height: 108,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, i) {
                      final p = _pets[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _open(PetDetailsScreen(petId: p.id)),
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            children: [
                              PetAvatar(
                                  photoUrl: p.photoUrl,
                                  emoji: p.emoji,
                                  radius: 32),
                              const SizedBox(height: 6),
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              _sectionTitle(
                  'Vaccination reminders', 'Overdue or due in the next 30 days'),
              if (_reminders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No vaccinations due soon. 🎉'),
                  ),
                )
              else
                ..._reminders.map(
                  (v) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.vaccines),
                      title: Text('${v.vaccineName} (${v.petName ?? 'Pet'})',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(v.reminderText),
                      trailing: VaccStatusChip(v.status),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.fullName.trim();
    final first = name.isEmpty ? 'there' : name.split(' ').first;
    return Scaffold(
      bottomNavigationBar:
      UserBottomNav(current: 0, onReturn: () => _load(showSpinner: false)),
      body: Column(
        children: [
          GradientHeader(
            appName: 'PetHub',
            title: 'Hi, $first! 👋',
            subtitle: "Let's take care of your furry friends",
            onLogout: () => logoutAndGoToLogin(context),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }
}