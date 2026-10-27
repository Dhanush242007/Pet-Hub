import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../models/profile.dart';
import '../../services/admin_service.dart';
import '../../services/error_helper.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_card.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Profile> _users = [];
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
      final users = await AdminService().getUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
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
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = ErrorView(message: _error!, onRetry: _load);
    } else if (_users.isEmpty) {
      body = const EmptyState(icon: Icons.people, title: 'No users yet');
    } else {
      body = RefreshIndicator(
        onRefresh: () => _load(showSpinner: false),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _users.length,
          itemBuilder: (_, i) {
            final u = _users[i];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                    child: Icon(u.isAdmin
                        ? Icons.admin_panel_settings
                        : Icons.person)),
                title: Text(u.fullName.isEmpty ? '(no name)' : u.fullName),
                subtitle: Text('${u.email}\nRole: ${u.role}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _UserPetsScreen(user: u))),
              ),
            );
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: body,
    );
  }
}

class _UserPetsScreen extends StatefulWidget {
  final Profile user;
  const _UserPetsScreen({required this.user});

  @override
  State<_UserPetsScreen> createState() => _UserPetsScreenState();
}

class _UserPetsScreenState extends State<_UserPetsScreen> {
  List<Pet> _pets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pets = await AdminService().getPetsOfUser(widget.user.id);
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
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = ErrorView(message: _error!, onRetry: _load);
    } else if (_pets.isEmpty) {
      body = const EmptyState(
          icon: Icons.pets, title: 'This user has no registered pets');
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _pets.length,
        itemBuilder: (_, i) => PetCard(pet: _pets[i]),
      );
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.user.fullName.isEmpty
              ? 'User pets'
              : "${widget.user.fullName}'s pets")),
      body: body,
    );
  }
}