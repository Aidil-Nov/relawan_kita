import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; // <--- IMPORT REMIX ICON

class EducationDetailPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content; // Isi panduan lengkap

  const EducationDetailPage({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Detail Panduan",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Icon Back otomatis (Arrow Left), tapi bisa dicustom kalau mau
        // leading: IconButton(icon: Icon(Remix.arrow_left_line), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER IKON BESAR
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                // Icon Besar
                child: Icon(icon, size: 80, color: color),
              ),
            ),
            const SizedBox(height: 30),

            // 2. JUDUL PANDUAN
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            
            // Garis Pembatas
            Divider(color: Colors.grey[200], thickness: 2),
            const SizedBox(height: 20),

            // 3. ISI KONTEN (Materi)
            Text(
              "Langkah-langkah Keselamatan:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87
              ),
            ),
            const SizedBox(height: 12),
            
            // Container agar teks rapi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.6, // Spasi antar baris agar mudah dibaca
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Selesai Membaca
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                // Icon Centang (Remix Icon)
                icon: const Icon(Remix.check_double_line, color: Colors.white, size: 20),
                label: const Text(
                  "Saya Mengerti",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}