class Pet {
  final String id;
  final String ownerId;
  final String registrationId;
  final String name;
  final String petType;
  final String? breed;
  final int? ageYears;
  final String gender;
  final String? color;
  final String ownerPhone;
  final String? city;
  final String vaccinationStatus;
  final bool isLost;
  final String? photoUrl;
  final DateTime createdAt;
  // Only filled when an admin loads pets together with the owner's profile
  final String? ownerName;
  final String? ownerEmail;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.registrationId,
    required this.name,
    required this.petType,
    this.breed,
    this.ageYears,
    required this.gender,
    this.color,
    required this.ownerPhone,
    this.city,
    required this.vaccinationStatus,
    required this.isLost,
    this.photoUrl,
    required this.createdAt,
    this.ownerName,
    this.ownerEmail,
  });

  static const List<String> types = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  static const List<String> genders = ['Male', 'Female', 'Unknown'];
  static const List<String> vaccStatuses = [
    'Vaccinated',
    'Partially Vaccinated',
    'Not Vaccinated'
  ];

  factory Pet.fromMap(Map<String, dynamic> m) {
    final owner = m['profiles'];
    return Pet(
      id: m['id'] as String,
      ownerId: m['owner_id'] as String,
      registrationId: m['registration_id'] as String,
      name: m['name'] as String,
      petType: m['pet_type'] as String,
      breed: m['breed'] as String?,
      ageYears: m['age_years'] as int?,
      gender: (m['gender'] ?? 'Unknown') as String,
      color: m['color'] as String?,
      ownerPhone: m['owner_phone'] as String,
      city: m['city'] as String?,
      vaccinationStatus: (m['vaccination_status'] ?? 'Not Vaccinated') as String,
      isLost: (m['is_lost'] ?? false) as bool,
      photoUrl: m['photo_url'] as String?,
      createdAt: DateTime.parse(m['created_at'] as String),
      ownerName: owner is Map ? owner['full_name'] as String? : null,
      ownerEmail: owner is Map ? owner['email'] as String? : null,
    );
  }

  String get emoji {
    switch (petType) {
      case 'Dog':
        return '🐶';
      case 'Cat':
        return '🐱';
      case 'Bird':
        return '🐦';
      case 'Rabbit':
        return '🐰';
      default:
        return '🐾';
    }
  }

  String get ageText {
    if (ageYears == null) return 'Unknown';
    return ageYears == 1 ? '1 year' : '$ageYears years';
  }
}