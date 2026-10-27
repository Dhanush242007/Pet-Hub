import '../config/supabase_config.dart';
import '../models/pet.dart';
import '../models/profile.dart';
import '../models/vaccination.dart';

/// These calls only return data if the logged-in user is an admin.
/// The database (RLS policies) enforces that, not the app.
class AdminService {
  Future<Map<String, int>> getStats() async {
    final users = await supabase.from('profiles').select('id');
    final pets = await supabase.from('pets').select('id');
    final lost = await supabase.from('pets').select('id').eq('is_lost', true);
    final vacc = await supabase.from('vaccinations').select('id');
    return {
      'users': users.length,
      'pets': pets.length,
      'lost': lost.length,
      'vaccinations': vacc.length,
    };
  }

  Future<List<Pet>> getAllPets() async {
    final rows = await supabase
        .from('pets')
        .select('*, profiles(full_name, email)')
        .order('created_at', ascending: false);
    return rows.map((r) => Pet.fromMap(r)).toList();
  }

  Future<List<Pet>> getLostPets() async {
    final rows = await supabase
        .from('pets')
        .select('*, profiles(full_name, email)')
        .eq('is_lost', true)
        .order('created_at', ascending: false);
    return rows.map((r) => Pet.fromMap(r)).toList();
  }

  Future<List<Pet>> getPetsOfUser(String userId) async {
    final rows = await supabase
        .from('pets')
        .select('*, profiles(full_name, email)')
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    return rows.map((r) => Pet.fromMap(r)).toList();
  }

  Future<List<Profile>> getUsers() async {
    final rows = await supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return rows.map((r) => Profile.fromMap(r)).toList();
  }

  Future<List<Vaccination>> getAllVaccinations() async {
    final rows = await supabase
        .from('vaccinations')
        .select('*, pets(name, registration_id)');
    final list = rows.map((r) => Vaccination.fromMap(r)).toList();
    // Records with a due date first (earliest first), the rest after
    list.sort((a, b) {
      if (a.nextDueDate == null && b.nextDueDate == null) return 0;
      if (a.nextDueDate == null) return 1;
      if (b.nextDueDate == null) return -1;
      return a.nextDueDate!.compareTo(b.nextDueDate!);
    });
    return list;
  }

  Future<void> deletePet(String id) async {
    await supabase.from('pets').delete().eq('id', id);
  }
}