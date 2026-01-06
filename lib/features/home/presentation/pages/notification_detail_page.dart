import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final String type; // 'alert' (laporan), 'success' (donasi), 'info' (umum)

  const NotificationDetailPage({
    super.key,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan Warna & Icon berdasarkan Tipe yang dikirim Backend
    // Backend types: 'success' (Donasi), 'alert' (Laporan), 'donation' (Donasi juga bisa)
    
    Color themeColor;
    IconData iconData;
    String actionLabel;
    
    // Normalisasi tipe string (jaga-jaga huruf besar/kecil)
    String safeType = type.toLowerCase();

    if (safeType.contains('alert') || safeType.contains('report')) {
      themeColor = Colors.red;
      iconData = Remix.alarm_warning_fill;
      actionLabel = "LIHAT DI PETA";
    } else if (safeType.contains('success') || safeType.contains('donation')) {
      themeColor = Colors.green;
      iconData = Remix.checkbox_circle_fill;
      actionLabel = "LIHAT RIWAYAT DONASI";
    } else {
      themeColor = Colors.blue;
      iconData = Remix.information_fill;
      actionLabel = "KEMBALI KE BERANDA";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Notifikasi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 60, color: themeColor),
              ),
            ),
            const SizedBox(height: 30),

            // 2. JUDUL
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 3. WAKTU
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // 4. ISI PESAN
            Text(
              "Isi Pesan:",
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Teks tambahan statis sebagai pemanis
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2))
              ),
              child: Row(
                children: [
                  const Icon(Remix.information_line, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Notifikasi ini dikirim otomatis oleh sistem RelawanKita.",
                      style: TextStyle(color: Colors.blue[800], fontSize: 12),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. TOMBOL AKSI
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Logika navigasi bisa ditambahkan di sini jika perlu
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Remix.arrow_left_line, color: Colors.white),
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