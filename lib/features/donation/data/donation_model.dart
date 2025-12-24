class DonationModel {
  final String donationId;
  final String userId; // Bisa kosong jika anonim
  final String disasterId;
  final double amount;
  final bool isAnonymous;
  final DateTime timestamp;

  DonationModel({
    required this.donationId,
    required this.userId,
    required this.disasterId,
    required this.amount,
    this.isAnonymous = false,
    required this.timestamp,
  });

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      donationId: map['donation_id'] ?? '',
      userId: map['user_id'] ?? 'ANONYMOUS',
      disasterId: map['disaster_id'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      isAnonymous: map['is_anonymous'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donation_id': donationId,
      'user_id': userId,
      'disaster_id': disasterId,
      'amount': amount,
      'is_anonymous': isAnonymous,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}