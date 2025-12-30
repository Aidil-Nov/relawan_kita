import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Pastikan package ini ada di pubspec.yaml
import 'package:remixicon/remixicon.dart';

// IMPORT MODEL (Sesuaikan path jika berbeda)
import 'package:relawan_kita/features/emergency/data/models/reports_model.dart';

class ReportDetailPage extends StatelessWidget {
  // UBAH: Menerima Object ReportModel, bukan Map lagi
  final ReportModel reportData;

  const ReportDetailPage({super.key, required this.reportData});

  // Helper: Warna Status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange; // pending
    }
  }

  // Helper: Teks Status Rapih
  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified': return "Selesai / Terverifikasi";
      case 'rejected': return "Ditolak";
      default: return "Menunggu Verifikasi";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna berdasarkan status API
    final Color statusColor = _getStatusColor(reportData.status);
    final String statusText = _formatStatus(reportData.status);

    // Format Tanggal (Ambil 10 karakter pertama: YYYY-MM-DD)
    final String displayDate = reportData.createdAt.length > 10 
        ? reportData.createdAt.substring(0, 10) 
        : reportData.createdAt;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white, 
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
          ),
          child: IconButton(
            icon: const Icon(Remix.arrow_left_line, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. BAGIAN PETA SIMULASI (40% Layar) - DESAIN ANDA
          Expanded(
            flex: 4, 
            child: Stack(
              children: [
                // Background Peta
                Container(color: const Color(0xFFE0E0E0)),
                
                // Jalan Raya (Hiasan visual)
                Positioned(
                  top: 0, bottom: 0, left: MediaQuery.of(context).size.width * 0.4, 
                  child: Container(width: 30, color: Colors.white70)
                ),
                Positioned(
                  top: 150, left: 0, right: 0, 
                  child: Container(height: 30, color: Colors.white70)
                ),

                // PIN LOKASI (Titik Merah)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)]
                        ),
                        child: Text(
                          reportData.category, // Data dari Model
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const Icon(Remix.map_pin_2_fill, color: Colors.red, size: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. BAGIAN DETAIL TEKS (60% Layar)
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor, 
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul (Category)
                  Text(
                    reportData.category, 
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Tanggal & Urgency
                  Row(
                    children: [
                      const Icon(Remix.calendar_line, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        displayDate, 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])
                      ),
                      const Spacer(),
                      if (reportData.urgency == 'Tinggi')
                        Row(
                          children: [
                            const Icon(Remix.alarm_warning_fill, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              "URGENSI TINGGI",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red[800]),
                            ),
                          ],
                        )
                    ],
                  ),
                  const Divider(height: 40),

                  // Deskripsi Header
                  Text(
                    "Kronologi Kejadian", 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                  const SizedBox(height: 10),
                  
                  // Isi Deskripsi
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        reportData.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6, 
                          color: Colors.black87
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tombol Share
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final String message = 
                          "🚨 LAPORAN BENCANA - RELAWAN KITA 🚨\n\n"
                          "📌 Kategori: ${reportData.category}\n"
                          "📅 Tanggal: $displayDate\n"
                          "📊 Status: $statusText\n\n"
                          "📝 Kronologi:\n${reportData.description}\n\n"
                          "📍 Lokasi:\n${reportData.locationAddress}\n\n"
                          "Mohon bantuan segera!";

                        Share.share(message);
                      }, 
                      icon: const Icon(Remix.share_circle_line),
                      label: const Text("Bagikan Laporan"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}