import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase -> Connect (or Project Settings -> API Keys)
  static const String url = 'https://vvsyswrirrjmgdqbdmhb.supabase.co';

  // Publishable key (sb_publishable_...) or the legacy anon key.
  // NEVER paste the secret / service_role key here.
  static const String anonKey = 'sb_publishable_X0lkHtWOjwmAv35SAqoglQ_4JuTQUKv';
}

/// Shortcut used everywhere: supabase.from('pets')...
/// (Only valid after Supabase.initialize() runs in main.dart)
SupabaseClient get supabase => Supabase.instance.client;