import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final String type; // 'alert', 'info', 'success'

  const NotificationDetailPage({
    super.key,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan Warna & Icon berdasarkan Tipe
    Color themeColor;
    IconData iconData;
    String actionLabel;

    switch (type) {
      case 'alert':
        themeColor = Colors.red;
        iconData = Remix.alarm_warning_fill;
        actionLabel = "LIHAT DI PETA";
        break;
      case 'success':
        themeColor = Colors.green;
        iconData = Remix.checkbox_circle_fill;
        actionLabel = "LIHAT RIWAYAT DONASI";
        break;
      default:
        themeColor = Colors.blue;
        iconData = Remix.information_fill;
        actionLabel = "KEMBALI KE BERANDA";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Notifikasi"),
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER ICON
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 50, color: themeColor),
              ),
            ),
            const SizedBox(height: 24),

            // 2. WAKTU
            Center(
              child: Text(
                time,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),

            // 3. JUDUL
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // 4. ISI PESAN
            Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: Colors.black54,
              ),
            ),
            
            // Tambahan teks dummy agar terlihat panjang
            const SizedBox(height: 16),
            Text(
              "Harap tetap tenang dan ikuti arahan dari petugas di lapangan. "
              "Jika Anda membutuhkan bantuan darurat, segera gunakan fitur 'Panic Button' di halaman utama aplikasi RelawanKita.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 40),

            // 5. TOMBOL AKSI
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Di sini nanti bisa diarahkan ke halaman Peta / History
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Remix.arrow_right_line, color: Colors.white),
                label: Text(
                  actionLabel, 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}