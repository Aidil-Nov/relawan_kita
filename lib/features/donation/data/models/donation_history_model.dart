class DonationHistoryModel {
  final int id;
  final String orderId;
  final double amount;
  final String status;
  final String snapToken;
  final String createdAt;
  // Data Kampanye (Relasi)
  final String campaignTitle;
  final String? campaignImage;

  DonationHistoryModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.snapToken,
    required this.createdAt,
    required this.campaignTitle,
    this.campaignImage,
  });

  factory DonationHistoryModel.fromJson(Map<String, dynamic> json) {
    return DonationHistoryModel(
      id: json['id'],
      orderId: json['order_id'],
      // Pastikan amount dibaca sebagai double
      amount: double.parse(json['amount'].toString()), 
      status: json['status'],
      snapToken: json['snap_token'] ?? '',
      createdAt: json['created_at'],
      // Ambil data dari relasi 'campaign' jika ada
      campaignTitle: json['campaign'] != null ? json['campaign']['title'] : 'Donasi Umum',
      campaignImage: json['campaign'] != null ? json['campaign']['image_url'] : null,
    );
  }
}