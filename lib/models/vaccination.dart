import 'package:intl/intl.dart';

enum VaccStatus { planned, overdue, upcoming, scheduled, completed }

class Vaccination {
  final String id;
  final String petId;
  final String vaccineName;
  final DateTime dateGiven;
  final DateTime? nextDueDate;
  final String? notes;
  // Only filled when loaded together with the pet
  final String? petName;
  final String? petRegId;

  const Vaccination({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.dateGiven,
    this.nextDueDate,
    this.notes,
    this.petName,
    this.petRegId,
  });

  factory Vaccination.fromMap(Map<String, dynamic> m) {
    final pet = m['pets'];
    return Vaccination(
      id: m['id'] as String,
      petId: m['pet_id'] as String,
      vaccineName: m['vaccine_name'] as String,
      dateGiven: DateTime.parse(m['date_given'] as String),
      nextDueDate: m['next_due_date'] == null
          ? null
          : DateTime.parse(m['next_due_date'] as String),
      notes: m['notes'] as String?,
      petName: pet is Map ? pet['name'] as String? : null,
      petRegId: pet is Map ? pet['registration_id'] as String? : null,
    );
  }

  /// Status is calculated from today's date.
  VaccStatus get status {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dateGiven.isAfter(today)) return VaccStatus.planned;
    if (nextDueDate == null) return VaccStatus.completed;
    if (nextDueDate!.isBefore(today)) return VaccStatus.overdue;
    if (nextDueDate!.difference(today).inDays <= 30) return VaccStatus.upcoming;
    return VaccStatus.scheduled;
  }

  /// The date that matters for reminders (planned = the booked date).
  DateTime get reminderDate =>
      status == VaccStatus.planned ? dateGiven : (nextDueDate ?? dateGiven);

  String get reminderText {
    final f = DateFormat('dd MMM yyyy');
    if (status == VaccStatus.planned) return 'Planned: ${f.format(dateGiven)}';
    if (nextDueDate == null) return 'No due date';
    return 'Due: ${f.format(nextDueDate!)}';
  }
}