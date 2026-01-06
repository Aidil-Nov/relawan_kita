import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/core/services/api_service.dart'; // Import API Service

// IMPORT MODEL
import 'package:relawan_kita/features/emergency/data/models/reports_model.dart';

// UBAH JADI STATEFUL WIDGET (Agar bisa handle loading cancel)
class ReportDetailPage extends StatefulWidget {
  final ReportModel reportData;

  const ReportDetailPage({super.key, required this.reportData});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  bool _isCanceling = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'canceled':
        return Colors.grey; // Warna untuk dibatalkan
      default:
        return Colors.orange;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return "Selesai / Terverifikasi";
      case 'rejected':
        return "Ditolak";
      case 'canceled':
        return "Dibatalkan User";
      default:
        return "Menunggu Verifikasi";
    }
  }

  // LOGIKA BATALKAN LAPORAN
  void _onCancelPressed() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan Laporan?"),
        content: const Text(
          "Laporan yang dibatalkan tidak akan diproses oleh admin. Aksi ini tidak dapat dikembalikan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Tutup Dialog
            child: const Text("Kembali"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup Dialog
              _processCancellation(); // Lanjut Proses
            },
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _processCancellation() async {
    setState(() => _isCanceling = true);

    // Panggil API
    bool success = await ApiService().cancelReport(widget.reportData.id);

    if (!mounted) return;
    setState(() => _isCanceling = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Laporan berhasil dibatalkan."),
          backgroundColor: Colors.grey,
        ),
      );
      Navigator.pop(context, true); // Kembali ke list & minta refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal membatalkan laporan."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                widget.reportData.photoUrl,
                errorBuilder: (c, e, s) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Remix.image_2_fill, color: Colors.white),
                    Text("Gagal memuat", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(widget.reportData.status);
    final String statusText = _formatStatus(widget.reportData.status);
    final String displayDate = widget.reportData.createdAt.length > 10
        ? widget.reportData.createdAt.substring(0, 10)
        : widget.reportData.createdAt;

    // Cek apakah status masih PENDING
    bool isPending = widget.reportData.status.toLowerCase() == 'pending';

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
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: IconButton(
            icon: const Icon(Remix.arrow_left_line, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. BAGIAN FOTO BUKTI
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () {
                if (widget.reportData.photoUrl.isNotEmpty)
                  _openFullScreenImage(context);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.reportData.photoUrl.isNotEmpty
                      ? Image.network(
                          widget.reportData.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(Remix.image_2_line),
                              ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Remix.image_2_line),
                        ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BAGIAN DETAIL TEKS
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul & Ticket
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.reportData.category,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                        ),
                      ),
                      Text(
                        "#${widget.reportData.ticketId}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lokasi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Remix.map_pin_2_fill,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.reportData.locationAddress,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tanggal
                  Row(
                    children: [
                      const Icon(
                        Remix.calendar_line,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        displayDate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      if (widget.reportData.urgency == 'Tinggi')
                        Row(
                          children: [
                            const Icon(
                              Remix.alarm_warning_fill,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "URGENSI TINGGI",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[800],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Alasan Penolakan (Jika ada)
                  if (widget.reportData.status == 'rejected' &&
                      widget.reportData.adminNote != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Alasan Penolakan:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.reportData.adminNote!,
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 30),
                  Text(
                    "Kronologi Kejadian",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.reportData.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- AREA TOMBOL ---
                  Column(
                    children: [
                      // Tombol Share (Selalu Ada)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final String message =
                                "🚨 LAPORAN BENCANA\n${widget.reportData.category}\nLokasi: ${widget.reportData.locationAddress}\n\n#RelawanKita";
                            Share.share(message);
                          },
                          icon: const Icon(Remix.share_circle_line),
                          label: const Text("Bagikan Laporan"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      // Tombol Batalkan (HANYA JIKA PENDING)
                      if (isPending) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCanceling ? null : _onCancelPressed,
                            icon: _isCanceling
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Remix.close_circle_line,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isCanceling
                                  ? "Memproses..."
                                  : "Batalkan Laporan",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
