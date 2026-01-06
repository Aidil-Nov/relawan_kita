class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type; // 'donation' atau 'report'
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'],
    );
  }
}