import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// Import Halaman Detail yang baru dibuat
import 'package:relawan_kita/features/home/presentation/pages/notification_detail_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data Notifikasi
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "PERINGATAN DINI: Siaga Banjir",
        "body": "Debit air di Bendungan A meningkat drastis akibat curah hujan tinggi. Warga di bantaran sungai harap segera mengamankan barang berharga dan bersiap evakuasi jika sirine berbunyi.",
        "time": "Baru saja",
        "type": "alert", 
      },
      {
        "title": "Laporan Diterima",
        "body": "Laporan kerusakan jalan yang Anda kirimkan telah kami terima. Saat ini tim relawan sedang melakukan verifikasi ke lokasi kejadian.",
        "time": "10 menit lalu",
        "type": "info",
      },
      {
        "title": "Donasi Berhasil Disalurkan",
        "body": "Terima kasih! Bantuan dana Anda sebesar Rp 100.000 telah disalurkan untuk korban Gempa Cianjur di Posko Pengungsian B.",
        "time": "1 jam lalu",
        "type": "success",
      },
      {
        "title": "Cuaca Ekstrem Besok",
        "body": "BMKG memprediksi hujan lebat disertai angin kencang di wilayah Anda mulai pukul 14.00 WIB besok. Hindari berteduh di bawah pohon besar.",
        "time": "2 jam lalu",
        "type": "info",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notifikasi",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isAlert = item['type'] == 'alert';

          return Container(
            color: isAlert ? Colors.red.withOpacity(0.05) : Colors.white, 
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isAlert ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: _getIcon(item['type']),
              ),
              title: Text(
                item['title'], 
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAlert ? Colors.red : Colors.black87
                )
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item['body'],
                    maxLines: 2, // Batasi 2 baris di list
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontSize: 13
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['time'], 
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11, 
                      color: Colors.grey
                    )
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                // --- NAVIGASI KE DETAIL PAGE ---
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailPage(
                      title: item['title'],
                      body: item['body'],
                      time: item['time'],
                      type: item['type'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper Icon
  Widget _getIcon(String type) {
    switch (type) {
      case 'alert':
        return const Icon(Remix.alarm_warning_fill, color: Colors.red, size: 24);
      case 'success':
        return const Icon(Remix.checkbox_circle_fill, color: Colors.green, size: 24);
      default:
        return const Icon(Remix.information_fill, color: Colors.blue, size: 24);
    }
  }
}