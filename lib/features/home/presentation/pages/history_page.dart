import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; // <--- IMPORT REMIX ICON

// Pastikan file ini ada (Halaman Detail Laporan yang menampilkan peta)
import 'package:relawan_kita/features/home/presentation/pages/report_detail_pages.dart'; 
// Jika file di atas belum ada/namanya beda, sesuaikan import-nya.

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            "Aktivitas Saya",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor, // Warna Biru Tema
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            labelStyle: Theme.of(context).textTheme.labelLarge, // Font Poppins Bold
            tabs: const [
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
class _ReportHistoryList extends StatelessWidget {
  const _ReportHistoryList();

  @override
  Widget build(BuildContext context) {
    // Simulasi Data Laporan
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
                    Text(
                      item['date'], 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          color: item['color'], 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins' // Paksa Poppins kalau Theme belum load sempurna
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                
                // Judul
                Text(
                  item['title'], 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                const Divider(),
                
                // TOMBOL LIHAT LOKASI (Updated)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetailPage(reportData: item),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Icon Map Pin (Remix)
                        Icon(Remix.map_pin_2_fill, size: 18, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Lihat Lokasi & Detail", 
                          style: TextStyle(
                            fontSize: 14, 
                            color: Theme.of(context).primaryColor, 
                            fontWeight: FontWeight.w600
                          )
                        ),
                        const Spacer(),
                        // Icon Arrow (Remix)
                        const Icon(Remix.arrow_right_s_line, size: 16, color: Colors.grey),
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
                // Icon Heart (Remix)
                child: const Icon(Remix.heart_3_fill, color: Colors.pink, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['campaign'], 
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['date'], 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)
                    ),
                  ],
                ),
              ),
              Text(
                item['amount'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}