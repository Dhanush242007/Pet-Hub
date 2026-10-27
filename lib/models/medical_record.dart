class MedicalRecord {
  final String id;
  final String petId;
  final DateTime visitDate;
  final String condition;
  final String? vetName;
  final String? treatment;

  const MedicalRecord({
    required this.id,
    required this.petId,
    required this.visitDate,
    required this.condition,
    this.vetName,
    this.treatment,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> m) {
    return MedicalRecord(
      id: m['id'] as String,
      petId: m['pet_id'] as String,
      visitDate: DateTime.parse(m['visit_date'] as String),
      condition: m['condition'] as String,
      vetName: m['vet_name'] as String?,
      treatment: m['treatment'] as String?,
    );
  }
}