import 'package:flutter/material.dart';
import 'report_detail_pages.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController diperlukan untuk membuat TabBar berfungsi
    return DefaultTabController(
      length: 2, // Jumlah Tab (Laporan & Donasi)
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Aktivitas Saya"),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(text: "Laporan Pengaduan"),
              Tab(text: "Riwayat Donasi"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReportHistoryList(),   // Isi Tab 1
            _DonationHistoryList(), // Isi Tab 2
          ],
        ),
      ),
    );
  }
}

// --- WIDGET TAB 1: RIWAYAT LAPORAN ---
// JANGAN LUPA IMPORT INI DI BAGIAN PALING ATAS FILE:

class _ReportHistoryList extends StatelessWidget {
  const _ReportHistoryList();

  @override
  Widget build(BuildContext context) {
    // Simulasi Data Laporan (DITAMBAHKAN FIELD 'description')
    final List<Map<String, dynamic>> reports = [
      {
        "title": "Pohon Tumbang di Jl. Ahmad Yani",
        "date": "24 Des 2024, 10:30",
        "status": "Selesai",
        "color": Colors.green,
        "description": "Pohon besar tumbang menutupi badan jalan akibat angin kencang. Tim Damkar telah melakukan pembersihan lokasi."
      },
      {
        "title": "Banjir Setinggi 50cm",
        "date": "23 Des 2024, 08:15",
        "status": "Diproses Relawan",
        "color": Colors.blue,
        "description": "Air sungai meluap masuk ke pemukiman warga RT 05. Warga membutuhkan bantuan logistik dan perahu karet."
      },
      {
        "title": "Jalan Berlubang Parah",
        "date": "20 Des 2024, 14:00",
        "status": "Menunggu Verifikasi",
        "color": Colors.orange,
        "description": "Lubang jalan sedalam 20cm sangat membahayakan pengendara motor, terutama saat malam hari."
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final item = reports[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Tanggal & Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['date'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(color: item['color'], fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                
                // Judul
                Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Divider(),
                
                // BAGIAN TOMBOL LIHAT LOKASI (YANG DI-UPDATE)
                InkWell(
                  onTap: () {
                    // Navigasi ke Halaman Detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetailPage(reportData: item),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8), // Efek klik melengkung
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Area klik diperluas sedikit
                    child: Row(
                      children: const [
                        Icon(Icons.location_on, size: 16, color: Colors.blueAccent),
                        SizedBox(width: 4),
                        Text("Lihat Lokasi & Detail", style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- WIDGET TAB 2: RIWAYAT DONASI ---
class _DonationHistoryList extends StatelessWidget {
  const _DonationHistoryList();

  @override
  Widget build(BuildContext context) {
    // Simulasi Data Donasi
    final List<Map<String, dynamic>> donations = [
      {
        "campaign": "Banjir Bandang Demak",
        "amount": "Rp 100.000",
        "date": "24 Des 2024",
      },
      {
        "campaign": "Gempa Cianjur Recovery",
        "amount": "Rp 50.000",
        "date": "20 Nov 2024",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final item = donations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.pink),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['campaign'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                item['amount'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        );
      },
    );
  }
}