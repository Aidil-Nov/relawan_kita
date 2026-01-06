class ReportModel {
  final int id;
  final String ticketId;
  final String category;
  final String urgency;
  final String description;
  final String locationAddress;
  
  // [BARU] Tambahkan field koordinat
  final double latitude;
  final double longitude;

  final String photoUrl;
  final String status;
  final String createdAt;
  final String? adminNote;

  ReportModel({
    required this.id,
    required this.ticketId,
    required this.category,
    required this.urgency,
    required this.description,
    required this.locationAddress,
    
    // [BARU] Wajib diisi
    required this.latitude,
    required this.longitude,

    required this.photoUrl,
    required this.status,
    required this.createdAt,
    this.adminNote,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk konversi aman ke Double
    // (Kadang API kirim string "-0.02" atau number -0.02)
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return ReportModel(
      id: json['id'],
      ticketId: json['ticket_id'] ?? '',
      category: json['category'] ?? 'Umum',
      urgency: json['urgency'] ?? 'Rendah',
      description: json['description'] ?? '',
      locationAddress: json['location_address'] ?? '',
      
      // [BARU] Parsing Koordinat Aman
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),

      photoUrl: json['photo_url'] ?? '', 
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      adminNote: json['admin_note'],
    );
  }
}