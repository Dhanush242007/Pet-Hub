import '../config/supabase_config.dart';
import '../models/medical_record.dart';

class MedicalService {
  Future<List<MedicalRecord>> getForPet(String petId) async {
    final rows = await supabase
        .from('medical_records')
        .select()
        .eq('pet_id', petId)
        .order('visit_date', ascending: false);
    return rows.map((r) => MedicalRecord.fromMap(r)).toList();
  }

  Future<void> add(String petId, Map<String, dynamic> data) async {
    await supabase.from('medical_records').insert({...data, 'pet_id': petId});
  }

  Future<void> delete(String id) async {
    await supabase.from('medical_records').delete().eq('id', id);
  }
}