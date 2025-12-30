class ReportModel {
  final int id;
  final String category;
  final String urgency;
  final String locationAddress;
  final String description;
  final String? imageUrl; // Bisa null jika tidak ada foto
  final String status;    // pending, verified, rejected
  final String createdAt;

  ReportModel({
    required this.id,
    required this.category,
    required this.urgency,
    required this.locationAddress,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  // Factory untuk mengubah JSON dari Backend menjadi Object Dart
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      
      // Pastikan key ini sama persis dengan kolom di Database Laravel
      category: json['category'] ?? 'Umum',
      urgency: json['urgency'] ?? 'Rendah',
      locationAddress: json['location_address'] ?? '-',
      description: json['description'] ?? '-',
      
      // Backend tadi mengirim 'image_url', bukan 'image_path' (karena sudah kita map di controller)
      imageUrl: json['image_url'], 
      
      status: json['status'] ?? 'pending',
      
      // Mengambil tanggal pembuatan
      createdAt: json['created_at'] ?? '',
    );
  }
}