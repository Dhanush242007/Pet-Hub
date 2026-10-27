class Profile {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'user' or 'admin'

  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: (map['full_name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      role: (map['role'] ?? 'user') as String,
    );
  }
}