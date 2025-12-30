class CertificateModel {
  final int id;
  final String title;
  final String issuer;
  final String certificateCode;
  final String? fileUrl;

  CertificateModel({
    required this.id,
    required this.title,
    required this.issuer,
    required this.certificateCode,
    this.fileUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'],
      title: json['title'],
      issuer: json['issuer'],
      certificateCode: json['certificate_code'], // Sesuai nama kolom database
      fileUrl: json['file_url'],
    );
  }
}