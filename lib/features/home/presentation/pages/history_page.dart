import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// --- IMPORTS LOGIC ---
import 'package:relawan_kita/core/services/api_service.dart';

// --- IMPORTS MODEL ---
import 'package:relawan_kita/features/emergency/data/models/reports_model.dart';
import 'package:relawan_kita/features/donation/data/models/donation_history_model.dart';

// --- IMPORT HALAMAN DETAIL ---
import 'package:relawan_kita/features/home/presentation/pages/report_detail_pages.dart';
import 'package:relawan_kita/features/donation/presentation/pages/midtrans_payment_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    bool login = await ApiService().isLoggedIn();
    if(mounted) setState(() => _isGuest = !login);
  }

  @override
  Widget build(BuildContext context) {
    // [TAMPILAN KHUSUS TAMU]
    if (_isGuest) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text("Aktivitas Saya"), centerTitle: true, elevation: 0, backgroundColor: Colors.white),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Remix.history_line, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text("Riwayat Kosong", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Silakan login untuk melihat riwayat aktivitas.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false),
                child: const Text("LOGIN SEKARANG"),
              )
            ],
          ),
        ),
      );
    }

    // [TAMPILAN USER LOGIN - SAMA SEPERTI SEBELUMNYA]
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text("Aktivitas Saya", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [Tab(text: "Laporan Pengaduan"), Tab(text: "Riwayat Donasi")],
          ),
        ),
        body: const TabBarView(children: [_ReportHistoryList(), _DonationHistoryList()]),
      ),
    );
  }
}

// ============================================================================
// TAB 1: RIWAYAT LAPORAN (GESTURE SWIPE & MULTI-SELECT)
// ============================================================================
class _ReportHistoryList extends StatefulWidget {
  const _ReportHistoryList();

  @override
  State<_ReportHistoryList> createState() => _ReportHistoryListState();
}

class _ReportHistoryListState extends State<_ReportHistoryList> {
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  // STATE UNTUK MULTI-SELECT
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {}; 

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    // Jangan set _isLoading=true di sini agar UX swipe tidak kedip
    final data = await ApiService().getMyReports();
    if (mounted) {
      setState(() {
        _reports = data;
        _isLoading = false;
        // Reset selection saat refresh
        _isSelectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  // --- LOGIC 1: HAPUS BANYAK (MULTI-SELECT) ---
  Future<void> _deleteSelectedReports() async {
    if (_selectedIds.isEmpty) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Laporan Terpilih?"),
        content: Text("Anda akan menghapus ${_selectedIds.length} laporan secara permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      // Panggil API Delete Massal
      bool success = await ApiService().deleteReports(_selectedIds.toList());
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
          _fetchReports(); // Refresh data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus data")));
        }
      }
    }
  }

  // --- LOGIC 2: BATALKAN LAPORAN (SWIPE KANAN) ---
  Future<bool> _cancelReportBySwipe(int id) async {
    bool success = await ApiService().cancelReport(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan dibatalkan")));
      _fetchReports(); // Refresh agar status berubah jadi Canceled
      return false; // Return false agar item TIDAK hilang dari list (hanya update status)
    }
    return false;
  }

  // --- LOGIC 3: HAPUS SATUAN (SWIPE KIRI) ---
  Future<bool> _deleteReportBySwipe(int id) async {
    bool success = await ApiService().deleteReports([id]);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan dihapus")));
      return true; // Return true agar item hilang dari list UI
    }
    return false;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified': return Colors.green;
      case 'rejected': return Colors.red;
      case 'canceled': return Colors.grey;
      default: return Colors.orange;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified': return "Selesai";
      case 'rejected': return "Ditolak";
      case 'canceled': return "Dibatalkan";
      default: return "Menunggu";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_reports.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchReports,
        child: ListView( 
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3), 
            Center(
              child: Column(
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

    // Gunakan Scaffold di dalam Tab agar bisa pakai FloatingActionButton
    return Scaffold(
      backgroundColor: Colors.transparent,
      
      // TOMBOL MELAYANG HAPUS MASSAL
      floatingActionButton: _isSelectionMode 
        ? FloatingActionButton.extended(
            onPressed: _deleteSelectedReports,
            backgroundColor: Colors.red,
            icon: const Icon(Remix.delete_bin_line, color: Colors.white),
            label: Text("Hapus (${_selectedIds.length})", style: const TextStyle(color: Colors.white)),
          )
        : null,

      body: RefreshIndicator(
        onRefresh: _fetchReports,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding bawah utk FAB
          itemCount: _reports.length,
          itemBuilder: (context, index) {
            final report = _reports[index];
            final statusColor = _getStatusColor(report.status);
            
            // Logic Status
            bool isPending = report.status == 'pending';
            bool canDelete = report.status != 'pending'; // Hanya yg batal/selesai bisa dihapus
            bool isSelected = _selectedIds.contains(report.id);

            // WIDGET CARD UTAMA
            Widget cardContent = Card(
              elevation: 0,
              color: isSelected ? Colors.blue.shade50 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.blue : Colors.grey.shade200, 
                  width: isSelected ? 2 : 1
                ),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (_isSelectionMode) {
                    // MODE SELECT: Toggle Pilih
                    if (canDelete) {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(report.id);
                          if (_selectedIds.isEmpty) _isSelectionMode = false;
                        } else {
                          _selectedIds.add(report.id);
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan aktif tidak bisa dipilih untuk dihapus."), duration: Duration(seconds: 1)));
                    }
                  } else {
                    // MODE NORMAL: Buka Detail
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage(reportData: report))).then((val) {
                      if (val == true) _fetchReports();
                    });
                  }
                },
                onLongPress: () {
                  // MASUK KE MODE SELECT
                  if (canDelete) {
                    setState(() {
                      _isSelectionMode = true;
                      _selectedIds.add(report.id);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan aktif tidak bisa dihapus.")));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // CHECKBOX (Mode Select)
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            isSelected ? Remix.checkbox_circle_fill : Remix.checkbox_blank_circle_line,
                            color: isSelected ? Colors.blue : (canDelete ? Colors.grey : Colors.grey.shade300),
                          ),
                        ),
                      
                      // ISI DATA
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(report.createdAt.length > 10 ? report.createdAt.substring(0, 10) : report.createdAt, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(_formatStatus(report.status), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(report.category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(report.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // JIKA MODE SELECT, DISABLE SWIPE AGAR TIDAK BENTROK
            if (_isSelectionMode) {
              return cardContent;
            }

            // FITUR GESER (SWIPE)
            return Dismissible(
              key: Key(report.id.toString()),
              // SWIPE KANAN (StartToEnd) -> BATALKAN
              // SWIPE KIRI (EndToStart) -> HAPUS
              direction: DismissDirection.horizontal,
              
              // Background Kanan (Cancel) - Oranye
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: Colors.orange,
                child: const Row(children: [Icon(Remix.close_circle_line, color: Colors.white), SizedBox(width: 8), Text("Batalkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
              ),

              // Background Kiri (Hapus) - Merah
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Remix.delete_bin_line, color: Colors.white)]),
              ),

              // LOGIKA CONFIRM SWIPE
              confirmDismiss: (direction) async {
                // 1. SWIPE KANAN: BATALKAN
                if (direction == DismissDirection.startToEnd) {
                  if (!isPending) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan ini tidak bisa dibatalkan lagi.")));
                    return false;
                  }
                  bool confirm = await showDialog(
                    context: context, 
                    builder: (c) => AlertDialog(
                      title: const Text("Batalkan Laporan?"), 
                      actions: [
                        TextButton(onPressed: ()=>Navigator.pop(c, false), child: const Text("Tidak")),
                        TextButton(onPressed: ()=>Navigator.pop(c, true), child: const Text("Ya")),
                      ]
                    )
                  ) ?? false;
                  
                  if (confirm) {
                    await _cancelReportBySwipe(report.id);
                    return false; // Jangan hapus card, cuma refresh
                  }
                } 
                
                // 2. SWIPE KIRI: HAPUS
                else if (direction == DismissDirection.endToStart) {
                  if (!canDelete) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan aktif tidak boleh dihapus.")));
                    return false;
                  }
                  bool confirm = await showDialog(
                    context: context, 
                    builder: (c) => AlertDialog(
                      title: const Text("Hapus Permanen?"), 
                      content: const Text("Data ini akan hilang selamanya."),
                      actions: [
                        TextButton(onPressed: ()=>Navigator.pop(c, false), child: const Text("Batal")),
                        TextButton(onPressed: ()=>Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                      ]
                    )
                  ) ?? false;

                  if (confirm) {
                    return await _deleteReportBySwipe(report.id); // Jika sukses, return true (Card hilang)
                  }
                }
                return false;
              },
              child: cardContent,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: RIWAYAT DONASI (TIDAK BERUBAH - HANYA RE-PASTE AGAR LENGKAP)
// ============================================================================
class _DonationHistoryList extends StatefulWidget {
  const _DonationHistoryList();

  @override
  State<_DonationHistoryList> createState() => _DonationHistoryListState();
}

class _DonationHistoryListState extends State<_DonationHistoryList> {
  List<DonationHistoryModel> _donations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    final data = await ApiService().getDonationHistory();
    if (mounted) {
      setState(() {
        _donations = data;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'settlement': 
      case 'capture':
      case 'success': return Colors.green;
      case 'pending': return Colors.orange;
      case 'deny':
      case 'expire':
      case 'cancel': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'settlement': 
      case 'capture':
      case 'success': return "Berhasil";
      case 'pending': return "Menunggu Bayar";
      case 'deny': return "Ditolak";
      case 'expire': return "Kadaluarsa";
      case 'cancel': return "Dibatalkan";
      default: return status;
    }
  }

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_donations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchDonations,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
             SizedBox(height: MediaQuery.of(context).size.height * 0.3),
             Center(child: Column(children: [Icon(Remix.hand_heart_line, size: 80, color: Colors.grey[300]), const SizedBox(height: 16), Text("Belum ada riwayat donasi", style: TextStyle(color: Colors.grey[600]))])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _donations.length,
        itemBuilder: (context, index) {
          final item = _donations[index];
          final statusColor = _getStatusColor(item.status);

          return GestureDetector(
            onTap: () {
              if (item.status == 'pending' && item.snapToken.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MidtransPaymentPage(snapToken: item.snapToken))).then((_) => _fetchDonations());
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.status == 'pending' ? Colors.orange.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.status == 'pending' ? Remix.time_line : Remix.heart_3_fill, color: item.status == 'pending' ? Colors.orange : Colors.pink, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.campaignTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item.createdAt.length > 10 ? item.createdAt.substring(0, 10) : item.createdAt, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(_getStatusText(item.status), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatCurrency(item.amount), style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 14)),
                      if(item.status == 'pending') const Padding(padding: EdgeInsets.only(top: 4.0), child: Text("Bayar >", style: TextStyle(fontSize: 10, color: Colors.blue)))
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}