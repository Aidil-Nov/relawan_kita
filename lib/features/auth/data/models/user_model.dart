enum UserRole { citizen, volunteer, donor, adminGov }
enum DisabilityType { none, deaf, blind, mobility }

class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String nik; // Enkripsi di backend/database, di sini string biasa
  final UserRole role;
  final bool isVerified;
  final DisabilityType disabilityType;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.nik = '',
    this.role = UserRole.citizen,
    this.isVerified = false,
    this.disabilityType = DisabilityType.none,
    required this.createdAt,
  });

  // Mengubah data dari Map (Database/JSON) ke Object Dart
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      nik: map['nik'] ?? '',
      role: UserRole.values.firstWhere(
          (e) => e.toString() == 'UserRole.${map['role']}',
          orElse: () => UserRole.citizen),
      isVerified: map['is_verified'] ?? false,
      disabilityType: DisabilityType.values.firstWhere(
          (e) => e.toString() == 'DisabilityType.${map['disability_type']}',
          orElse: () => DisabilityType.none),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Mengubah Object Dart ke Map (untuk dikirim ke Database)
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'nik': nik,
      'role': role.toString().split('.').last, // Simpan sebagai string 'citizen'
      'is_verified': isVerified,
      'disability_type': disabilityType.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }
}