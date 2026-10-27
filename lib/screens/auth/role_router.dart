import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart';
import 'login_screen.dart';

/// Looks up the role in the database and opens the matching dashboard.
Future<void> goToDashboard(BuildContext context) async {
  final auth = AuthService();
  Widget target;

  try {
    final profile = await auth.getCurrentProfile();

    if (profile == null) {
      await auth.signOut();
      target = const LoginScreen();
    } else if (profile.isAdmin) {
      target = AdminDashboard(profile: profile);
    } else {
      target = UserDashboard(profile: profile);
    }
  } catch (_) {
    try {
      await auth.signOut();
    } catch (_) {}
    target = const LoginScreen();
  }

  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => target),
    (route) => false,
  );
}

/// Logs out and returns to the login screen.
Future<void> logoutAndGoToLogin(BuildContext context) async {
  await AuthService().signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}