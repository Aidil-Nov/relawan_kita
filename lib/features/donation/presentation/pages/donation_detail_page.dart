import 'package:flutter/material.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Masukan Nominal Donasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                child: const Text("LANJUT PEMBAYARAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text("Terima Kasih!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Donasi Anda sedang diproses. Notifikasi akan dikirim setelah verifikasi pembayaran.", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))
        ],
      ),
    );
  }

  Widget _nominalButton(String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.collected / widget.target;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.title, style: const TextStyle(fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Image.asset(widget.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bar Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Terkumpul", style: TextStyle(color: Colors.grey[600])),
                      Text("Target", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rp ${widget.collected.toStringAsFixed(0)}jt", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pink)),
                      Text("Rp ${widget.target.toStringAsFixed(0)}jt", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress, 
                    backgroundColor: Colors.grey[200], 
                    color: Colors.pink, 
                    minHeight: 8
                  ),
                  const SizedBox(height: 24),

                  // Organizer Info
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.verified_user)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Diselenggarakan oleh:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text("Pemda & BPBD Kota", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                    ],
                  ),
                  const Divider(height: 40),

                  // Description
                  const Text("Cerita Penggalangan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(_description, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                  
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showPaymentSheet,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: const Text("DONASI SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}