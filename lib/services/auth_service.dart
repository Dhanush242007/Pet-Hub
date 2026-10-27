import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/profile.dart';

class AuthService {
  /// Creates an account. Returns true if the user is logged in right away
  /// (this happens when "Confirm email" is turned OFF in Supabase).
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
    return response.session != null;
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  bool get isLoggedIn => supabase.auth.currentSession != null;

  /// Reads the logged-in user's profile (including role) from the database.
  Future<Profile?> getCurrentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromMap(data);
  }

  /// Turns Supabase errors into friendly messages.
  static String friendlyError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login')) return 'Wrong email or password.';
      if (msg.contains('already registered')) {
        return 'This email is already registered. Please log in.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Please confirm your email first.';
      }
      if (msg.contains('rate limit')) {
        return 'Too many attempts. Please wait a minute and try again.';
      }
      return error.message;
    }
    return 'Something went wrong. Check your internet and try again.';
  }
}