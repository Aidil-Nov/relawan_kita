import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/donation/presentation/pages/midtrans_payment_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart'; // Import Login

class DonationDetailPage extends StatefulWidget {
  final int id;
  final String title;
  final String imageUrl;
  final double collected;
  final double target;

  const DonationDetailPage({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.collected,
    required this.target,
  });

  @override
  State<DonationDetailPage> createState() => _DonationDetailPageState();
}

class _DonationDetailPageState extends State<DonationDetailPage> {
  final TextEditingController _amountController = TextEditingController();
  late double _currentCollected;

  final String _description = "Bencana banjir bandang telah melumpuhkan aktivitas warga di 3 kecamatan. "
      "Saat ini, lebih dari 500 kepala keluarga mengungsi di posko darurat. "
      "Kami membutuhkan bantuan Anda untuk pengadaan:\n\n"
      "1. Makanan Siap Saji\n"
      "2. Selimut & Pakaian\n"
      "3. Obat-obatan & Vitamin\n\n"
      "Setiap rupiah yang Anda sumbangkan akan langsung disalurkan oleh tim RelawanKita yang sudah berada di lokasi.";

  @override
  void initState() {
    super.initState();
    _currentCollected = widget.collected;
  }

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processDonation(int amount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final String? snapToken = await ApiService().createDonation(widget.id, amount);

    if (!mounted) return;
    Navigator.pop(context); 

    if (snapToken != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MidtransPaymentPage(snapToken: snapToken)),
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 10), Text("Memverifikasi pembayaran...", style: TextStyle(color: Colors.white))])),
        );

        await ApiService().getDonationHistory();

        if (mounted) {
          Navigator.pop(context);
          setState(() => _currentCollected += amount);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Donasi Berhasil! Terima kasih orang baik."), backgroundColor: Colors.green));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuat transaksi. Cek koneksi internet.")));
    }
  }

  void _showPaymentSheet() {
    if (_currentCollected >= widget.target) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Donasi ini sudah terpenuhi!")));
      return;
    }

    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masukan Nominal Donasi", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [_nominalButton("10rb", 10000), const SizedBox(width: 8), _nominalButton("50rb", 50000), const SizedBox(width: 8), _nominalButton("100rb", 100000)]),
              const SizedBox(height: 16),
              TextField(controller: _amountController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: InputDecoration(prefixText: "Rp ", hintText: "Atau ketik nominal lain...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = int.tryParse(_amountController.text) ?? 0;
                    if (amount < 1000) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Minimal donasi Rp 1.000")));
                      return;
                    }
                    Navigator.pop(context);
                    _processDonation(amount);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("LANJUT PEMBAYARAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _nominalButton(String label, int value) {
    return Expanded(child: OutlinedButton(onPressed: () => _amountController.text = value.toString(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(label, style: const TextStyle(color: Colors.black87))));
  }

  // --- LOGIC TOMBOL DONASI (PROTEKSI) ---
  void _onDonatePressed() async {
    // 1. Cek Login
    bool isLogin = await ApiService().isLoggedIn();
    
    if (!isLogin) {
      // 2. Jika Tamu -> Tampilkan Dialog
      if (!mounted) return;
      showDialog(
        context: context, 
        builder: (ctx) => AlertDialog(
          title: const Text("Login Diperlukan"),
          content: const Text("Anda harus login untuk melakukan donasi."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            TextButton(onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginPage()));
            }, child: const Text("Login")),
          ],
        )
      );
      return;
    }

    // 3. Jika User -> Lanjut
    _showPaymentSheet();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (widget.target > 0) ? (_currentCollected / widget.target) : 0.0;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;
    bool isCompleted = _currentCollected >= widget.target;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            leading: IconButton(icon: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Icon(Remix.arrow_left_line, color: Colors.white)), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(title: Text(widget.title, style: const TextStyle(fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 10)], fontWeight: FontWeight.bold, color: Colors.white)), background: Stack(fit: StackFit.expand, children: [Image.network(widget.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey)), Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)])))])),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Terkumpul", style: Theme.of(context).textTheme.bodySmall), Text("Target", style: Theme.of(context).textTheme.bodySmall)]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_formatCurrency(_currentCollected), style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : Colors.pink, fontSize: 18)), Text(_formatCurrency(widget.target), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18))]),
                  const SizedBox(height: 10),
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[100], color: isCompleted ? Colors.green : Colors.pink, minHeight: 8)),
                  const SizedBox(height: 24),
                  Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Remix.government_fill, color: Colors.blueAccent)), const SizedBox(width: 12), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Diselenggarakan oleh:", style: TextStyle(fontSize: 10)), Text("Pemda & BPBD Kota", style: TextStyle(fontWeight: FontWeight.bold))]), const Spacer(), const Icon(Remix.verified_badge_fill, color: Colors.blue, size: 24)]),
                  const Divider(height: 40),
                  Text("Cerita Penggalangan", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(_description, style: const TextStyle(height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            // [MODIFIKASI] Panggil fungsi _onDonatePressed (Proteksi)
            onPressed: isCompleted ? null : _onDonatePressed,
            style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.grey : Colors.pink, disabledBackgroundColor: Colors.grey[300], disabledForegroundColor: Colors.grey[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(isCompleted ? "DONASI TERPENUHI" : "DONASI SEKARANG", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}