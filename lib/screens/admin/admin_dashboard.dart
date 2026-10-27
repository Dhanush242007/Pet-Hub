import 'package:flutter/material.dart';

import '../../models/profile.dart';
import '../../services/admin_service.dart';
import '../../services/error_helper.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/empty_state.dart';
import '../auth/role_router.dart';
import 'admin_lost_screen.dart';
import 'admin_pets_screen.dart';
import 'admin_users_screen.dart';
import 'admin_vaccinations_screen.dart';

class AdminDashboard extends StatefulWidget {
  final Profile profile;
  const AdminDashboard({super.key, required this.profile});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, int> _stats = {};
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
      final stats = await AdminService().getStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
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

  Widget _stat(IconData icon, String label, String key, Color color) {
    return StatTile(
        icon: icon, value: '${_stats[key] ?? 0}', label: label, color: color);
  }

  Widget _navTile(
      IconData icon, Color color, String title, String subtitle, Widget screen) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _open(screen),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: RefreshIndicator(
          onRefresh: () => _load(showSpinner: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _stat(Icons.people, 'Total users', 'users', Colors.blue),
                  _stat(Icons.pets, 'Total pets', 'pets', Colors.orange),
                  _stat(Icons.report_problem, 'Lost pets', 'lost', Colors.red),
                  _stat(Icons.vaccines, 'Vaccination records', 'vaccinations',
                      Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              _navTile(Icons.pets, Colors.orange, 'Manage Pet Registrations',
                  'View, search and delete registrations',
                  const AdminPetsScreen()),
              _navTile(Icons.people, Colors.blue, 'Manage Users',
                  'View users and their pets', const AdminUsersScreen()),
              _navTile(Icons.report_problem, Colors.red, 'Lost Pets',
                  'Pets currently marked as lost', const AdminLostScreen()),
              _navTile(Icons.vaccines, Colors.green, 'Vaccination Overview',
                  'Upcoming and overdue vaccinations',
                  const AdminVaccinationsScreen()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.fullName.trim();
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            appName: 'PetHub Admin',
            title: 'Hello, ${name.isEmpty ? 'Admin' : name} 🛡️',
            subtitle: 'Overview of all registrations',
            colors: const [Color(0xFF5B6CFF), Color(0xFF9B6BFF)],
            onLogout: () => logoutAndGoToLogin(context),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }
}