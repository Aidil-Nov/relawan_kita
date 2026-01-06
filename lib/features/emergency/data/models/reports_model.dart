class ReportModel {
  final int id;
  final String ticketId;
  final String category;
  final String urgency;
  final String description;
  final String locationAddress;
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
    required this.photoUrl,
    required this.status,
    required this.createdAt,
    this.adminNote,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      ticketId: json['ticket_id'],
      category: json['category'],
      urgency: json['urgency'],
      description: json['description'],
      locationAddress: json['location_address'],
      // Pastikan URL gambar valid
      photoUrl: json['photo_url'] ?? '', 
      status: json['status'],
      createdAt: json['created_at'],
      adminNote: json['admin_note'],
    );
  }
}