class CampaignModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final double targetAmount;
  final double collectedAmount;
  final String organizer;

  CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetAmount,
    required this.collectedAmount,
    required this.organizer,
  });

  // Fungsi untuk mengubah JSON dari Laravel menjadi Object Flutter
  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      // Handle jika image_url null
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/300', 
      // Pastikan angka dibaca sebagai double
      targetAmount: double.parse(json['target_amount'].toString()),
      collectedAmount: double.parse(json['collected_amount'].toString()),
      organizer: json['organizer'],
    );
  }
}