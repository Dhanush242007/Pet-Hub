import '../config/supabase_config.dart';
import '../models/pet.dart';

class PetService {
  Future<List<Pet>> getMyPets() async {
    final uid = supabase.auth.currentUser!.id;
    final rows = await supabase
        .from('pets')
        .select()
        .eq('owner_id', uid)
        .order('created_at', ascending: false);
    return rows.map((r) => Pet.fromMap(r)).toList();
  }

  Future<Pet> getPet(String id) async {
    final row = await supabase.from('pets').select().eq('id', id).single();
    return Pet.fromMap(row);
  }

  /// owner_id and registration_id are filled in by the database itself.
  Future<Pet> addPet(Map<String, dynamic> data) async {
    final row = await supabase.from('pets').insert(data).select().single();
    return Pet.fromMap(row);
  }

  Future<void> updatePet(String id, Map<String, dynamic> data) async {
    await supabase.from('pets').update(data).eq('id', id);
  }

  Future<void> setLost(String id, bool lost) async {
    await supabase.from('pets').update({'is_lost': lost}).eq('id', id);
  }

  Future<void> deletePet(String id) async {
    await supabase.from('pets').delete().eq('id', id);
  }
}