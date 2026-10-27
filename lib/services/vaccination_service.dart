import '../config/supabase_config.dart';
import '../models/vaccination.dart';
import '../widgets/format.dart';

class VaccinationService {
  Future<List<Vaccination>> getForPet(String petId) async {
    final rows = await supabase
        .from('vaccinations')
        .select()
        .eq('pet_id', petId)
        .order('date_given', ascending: false);
    return rows.map((r) => Vaccination.fromMap(r)).toList();
  }

  Future<void> add(String petId, Map<String, dynamic> data) async {
    await supabase.from('vaccinations').insert({...data, 'pet_id': petId});
  }

  Future<void> delete(String id) async {
    await supabase.from('vaccinations').delete().eq('id', id);
  }

  /// Overdue / due within 30 days / planned within 30 days (dashboard).
  /// The database only returns the logged-in user's own records.
  Future<List<Vaccination>> getReminders() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final t = dbDate(today);
    final l = dbDate(today.add(const Duration(days: 30)));

    final rows = await supabase
        .from('vaccinations')
        .select('*, pets(name, registration_id)')
        .or('next_due_date.lte.$l,and(date_given.gt.$t,date_given.lte.$l)');

    final list = rows.map((r) => Vaccination.fromMap(r)).toList();
    list.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
    return list;
  }
}