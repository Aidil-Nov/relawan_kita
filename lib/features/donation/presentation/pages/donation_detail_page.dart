import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; // <--- IMPORT REMIX ICON

class DonationDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final double collected;
  final double target;

  const DonationDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.collected,
    required this.target,
  });

  @override
  State<DonationDetailPage> createState() => _DonationDetailPageState();
}

class _DonationDetailPageState extends State<DonationDetailPage> {
  // Simulasi Text Cerita
  final String _description = 
      "Bencana banjir bandang telah melumpuhkan aktivitas warga di 3 kecamatan. "
      "Saat ini, lebih dari 500 kepala keluarga mengungsi di posko darurat. "
      "Kami membutuhkan bantuan Anda untuk pengadaan:\n\n"
      "1. Makanan Siap Saji\n"
      "2. Selimut & Pakaian\n"
      "3. Obat-obatan & Vitamin\n\n"
      "Setiap rupiah yang Anda sumbangkan akan langsung disalurkan oleh tim RelawanKita yang sudah berada di lokasi. "
      "Laporan penggunaan dana akan diupdate secara transparan melalui fitur 'Jurnal Relawan' di aplikasi ini.";

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masukan Nominal Donasi", 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _nominalButton("10rb"),
                const SizedBox(width: 8),
                _nominalButton("50rb"),
                const SizedBox(width: 8),
                _nominalButton("100rb"),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "Rp ",
                hintText: "Atau ketik nominal lain...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pink),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup Sheet
                  _showSuccessDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "LANJUT PEMBAYARAN", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Sukses Remix
            const Icon(Remix.checkbox_circle_fill, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text(
              "Terima Kasih!", 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(
              "Donasi Anda sedang diproses. Notifikasi akan dikirim setelah verifikasi pembayaran.", 
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  Widget _nominalButton(String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.collected / widget.target;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Remix.arrow_left_line, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.title, 
                style: const TextStyle(
                  fontSize: 14, 
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  fontFamily: 'Poppins', // Paksa Poppins di SliverAppBar
                  fontWeight: FontWeight.bold
                )
              ),
              background: Image.asset(widget.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bar Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Terkumpul", style: Theme.of(context).textTheme.bodySmall),
                      Text("Target", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp ${widget.collected.toStringAsFixed(0)}jt", 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, 
                          color: Colors.pink
                        )
                      ),
                      Text(
                        "Rp ${widget.target.toStringAsFixed(0)}jt", 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress, 
                      backgroundColor: Colors.grey[100], 
                      color: Colors.pink, 
                      minHeight: 8
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Organizer Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle
                        ),
                        // Icon Instansi Pemerintah (Remix)
                        child: const Icon(Remix.government_fill, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Diselenggarakan oleh:", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                          Text(
                            "Pemda & BPBD Kota", 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Verified Badge (Remix)
                      const Icon(Remix.verified_badge_fill, color: Colors.blue, size: 24),
                    ],
                  ),
                  const Divider(height: 40),

                  // Description
                  Text(
                    "Cerita Penggalangan", 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _description, 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6, 
                      color: Colors.black87
                    )
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showPaymentSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0
            ),
            child: const Text("DONASI SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}