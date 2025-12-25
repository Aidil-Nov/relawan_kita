import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
 // Import package share_plus

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportDetailPage({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    // Logika warna status dinamis
    Color statusColor = Colors.grey;
    if (reportData['status'] == 'Selesai') statusColor = Colors.green;
    if (reportData['status'] == 'Diproses Relawan') statusColor = Colors.blue;
    if (reportData['status'] == 'Menunggu Verifikasi') statusColor = Colors.orange;

    return Scaffold(
      extendBodyBehindAppBar: true, // Agar peta di belakang status bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. BAGIAN PETA SIMULASI (40% Layar)
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
                          boxShadow: [const BoxShadow(blurRadius: 5, color: Colors.black26)]
                        ),
                        child: Text(reportData['title'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.location_on, color: Colors.red, size: 40),
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
                      reportData['status'],
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul & Tanggal
                  Text(reportData['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(reportData['date'], style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const Divider(height: 40),

                  // Deskripsi
                  const Text("Kronologi Kejadian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    reportData['description'] ?? "Tidak ada deskripsi rinci.",
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),
                  
                  const Spacer(),
                  
                  // Tombol Share (SUDAH BERFUNGSI)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // 1. Ambil Data dari variabel reportData
                        final String title = reportData['title'];
                        final String status = reportData['status'];
                        final String date = reportData['date'];
                        final String desc = reportData['description'] ?? "Segera butuh bantuan.";
                        
                        // 2. Link Google Maps Simulasi
                        const String mapsLink = "https://maps.google.com/?q=Lokasi+Bencana";

                        // 3. Susun Pesan yang Rapi
                        final String message = 
                          "🚨 LAPORAN BENCANA - RELAWAN KITA 🚨\n\n"
                          "📌 Judul: $title\n"
                          "📅 Waktu: $date\n"
                          "📊 Status: $status\n\n"
                          "📝 Kronologi:\n$desc\n\n"
                          "📍 Lokasi Kejadian:\n$mapsLink\n\n"
                          "Mohon bantuan segera!";

                        // 4. Panggil Fungsi Share
                        Share.share(message);
                      }, 
                      icon: const Icon(Icons.share),
                      label: const Text("Bagikan Lokasi"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
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