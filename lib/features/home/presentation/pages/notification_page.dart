import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data Notifikasi
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "PERINGATAN DINI: Siaga Banjir",
        "body": "Debit air di Bendungan A meningkat. Warga di bantaran sungai harap waspada.",
        "time": "Baru saja",
        "type": "alert", // Tipe bahaya
      },
      {
        "title": "Laporan Diterima",
        "body": "Laporan kerusakan jalan Anda sedang diverifikasi oleh petugas.",
        "time": "10 menit lalu",
        "type": "info",
      },
      {
        "title": "Donasi Berhasil Disalurkan",
        "body": "Bantuan Anda telah sampai di Posko Pengungsian B.",
        "time": "1 jam lalu",
        "type": "success",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            color: item['type'] == 'alert' ? Colors.red[50] : Colors.white, // Highlight merah jika darurat
            child: ListTile(
              leading: _getIcon(item['type']),
              title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item['body']),
                  const SizedBox(height: 4),
                  Text(item['time'], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                // Nanti saat ada database, ini akan update status 'read'
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getIcon(String type) {
    switch (type) {
      case 'alert':
        return const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30);
      case 'success':
        return const Icon(Icons.check_circle, color: Colors.green, size: 30);
      default:
        return const Icon(Icons.info, color: Colors.blue, size: 30);
    }
  }
}