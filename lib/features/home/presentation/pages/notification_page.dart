import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/home/data/models/notification_model.dart';
// [BARU] Import Halaman Detail
import 'package:relawan_kita/features/home/presentation/pages/notification_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final data = await ApiService().getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _fetchNotifications, // Tombol Refresh Manual
            icon: const Icon(Remix.refresh_line),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Remix.notification_off_line, size: 50, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada notifikasi",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item) {
    // Tentukan Icon & Warna berdasarkan Tipe
    IconData icon;
    Color color;

    // Normalisasi string tipe agar tidak case sensitive
    String type = item.type.toLowerCase();

    if (type.contains('donation') || type.contains('success')) {
      icon = Remix.hand_heart_fill;
      color = Colors.pink;
    } else if (type.contains('report') || type.contains('alert')) {
      icon = Remix.checkbox_circle_fill;
      color = Colors.blue;
    } else {
      icon = Remix.information_fill;
      color = Colors.grey;
    }

    // [BARU] Bungkus dengan InkWell untuk Navigasi
    return InkWell(
      onTap: () {
        // Navigasi ke Detail Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailPage(
              title: item.title,
              body: item.message,
              time: _formatDate(item.createdAt),
              type: item.type, // Kirim tipe asli untuk logika warna di detail
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Bulat
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(item.createdAt), // Helper Format Tanggal
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    // Format tanggal sederhana dari "2024-05-20 10:00:00" ke "20/05 10:00"
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }
}