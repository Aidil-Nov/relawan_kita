import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// --- IMPORTS LOGIC ---
import 'package:relawan_kita/core/services/api_service.dart';

// --- IMPORTS MODEL ---
// Pastikan path ini sesuai dengan file reports_model.dart kamu
import 'package:relawan_kita/features/emergency/data/models/reports_model.dart';

// --- IMPORT HALAMAN DETAIL ---
// Pastikan path ini sesuai dengan file report_detail_pages.dart kamu
import 'package:relawan_kita/features/home/presentation/pages/report_detail_pages.dart';

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
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Laporan Pengaduan"),
              Tab(text: "Riwayat Donasi"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReportHistoryList(),   // Tab 1: DATA ASLI (API) + Pull to Refresh
            _DonationHistoryList(), // Tab 2: DATA DUMMY
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: RIWAYAT LAPORAN (CONNECTED TO API + REFRESH INDICATOR)
// ============================================================================
class _ReportHistoryList extends StatefulWidget {
  const _ReportHistoryList();

  @override
  State<_ReportHistoryList> createState() => _ReportHistoryListState();
}

class _ReportHistoryListState extends State<_ReportHistoryList> {
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  // UBAH: Menggunakan Future<void> agar RefreshIndicator bekerja
  Future<void> _fetchReports() async {
    final data = await ApiService().getMyReports();
    if (mounted) {
      setState(() {
        _reports = data;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange; // Pending
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified': return "Terverifikasi";
      case 'rejected': return "Ditolak";
      default: return "Menunggu Verifikasi";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      // FITUR REFRESH SAAT KOSONG
      return RefreshIndicator(
        onRefresh: _fetchReports,
        child: ListView( 
          physics: const AlwaysScrollableScrollPhysics(), // Wajib ada biar bisa ditarik
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3), 
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Remix.file_list_3_line, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada laporan", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // FITUR REFRESH SAAT ADA DATA
    return RefreshIndicator(
      onRefresh: _fetchReports,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // Wajib ada
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          final statusColor = _getStatusColor(report.status);

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
                        report.createdAt.length > 10 
                            ? report.createdAt.substring(0, 10) 
                            : report.createdAt, 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatStatus(report.status),
                          style: TextStyle(
                            color: statusColor, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Judul (Category) & Urgency
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.category, 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (report.urgency == 'Tinggi')
                        const Icon(Remix.alarm_warning_fill, color: Colors.red, size: 16)
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  // Deskripsi Singkat
                  Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                  const SizedBox(height: 8),
                  const Divider(),
                  
                  // TOMBOL LIHAT LOKASI
                  InkWell(
                    onTap: () {
                      // Navigasi ke Halaman Detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailPage(reportData: report), 
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
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
      ),
    );
  }
}

// ============================================================================
// TAB 2: RIWAYAT DONASI (MASIH DUMMY)
// ============================================================================
class _DonationHistoryList extends StatelessWidget {
  const _DonationHistoryList();

  @override
  Widget build(BuildContext context) {
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