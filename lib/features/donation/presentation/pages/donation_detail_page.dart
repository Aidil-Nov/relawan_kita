import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // PENTING: Untuk input angka
import 'package:remixicon/remixicon.dart';

// Import Halaman Waiting Page (Pastikan path-nya benar)
import 'package:relawan_kita/features/donation/presentation/pages/payment_waiting_page.dart';

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
  // 1. DEFINISI CONTROLLER YANG HILANG
  final TextEditingController _amountController = TextEditingController();
  
  // Variabel untuk menyimpan metode bayar yang dipilih
  String _selectedPaymentMethod = "bca"; 

  // Simulasi Text Cerita
  final String _description = 
      "Bencana banjir bandang telah melumpuhkan aktivitas warga di 3 kecamatan. "
      "Saat ini, lebih dari 500 kepala keluarga mengungsi di posko darurat. "
      "Kami membutuhkan bantuan Anda untuk pengadaan:\n\n"
      "1. Makanan Siap Saji\n"
      "2. Selimut & Pakaian\n"
      "3. Obat-obatan & Vitamin\n\n"
      "Setiap rupiah yang Anda sumbangkan akan langsung disalurkan oleh tim RelawanKita yang sudah berada di lokasi.";

  @override
  void dispose() {
    _amountController.dispose(); // Bersihkan memori
    super.dispose();
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
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
                  
                  // PILIHAN NOMINAL CEPAT
                  Row(
                    children: [
                      // Panggil fungsi dengan 2 parameter (Label, Nilai)
                      _nominalButton("10rb", 10000),
                      const SizedBox(width: 8),
                      _nominalButton("50rb", 50000),
                      const SizedBox(width: 8),
                      _nominalButton("100rb", 100000),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // INPUT MANUAL
                  TextField(
                    controller: _amountController, // Pasang Controller di sini
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Pastikan import services.dart ada
                    decoration: InputDecoration(
                      prefixText: "Rp ",
                      hintText: "Atau ketik nominal lain...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PILIH METODE PEMBAYARAN
                  Text(
                    "Pilih Metode Pembayaran", 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(setModalState, "bca", "Bank BCA"),
                  _buildPaymentOption(setModalState, "bri", "Bank BRI"),
                  _buildPaymentOption(setModalState, "gopay", "GoPay/QRIS"),
                  const SizedBox(height: 24),
                  
                  // TOMBOL LANJUT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_amountController.text.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi nominal dulu")));
                           return;
                        }
                        
                        Navigator.pop(context); // Tutup sheet
                        
                        // LANJUT KE HALAMAN WAITING (Pastikan file payment_waiting_page.dart sudah dibuat)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentWaitingPage(
                              amount: _amountController.text,
                              method: _selectedPaymentMethod,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("BAYAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // WIDGET TOMBOL NOMINAL (FIXED: Menerima 2 Parameter)
  Widget _nominalButton(String label, int value) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          // Isi text field otomatis saat tombol diklik
          _amountController.text = value.toString();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  Widget _buildPaymentOption(StateSetter setModalState, String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setModalState(() => _selectedPaymentMethod = val!);
      },
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      secondary: const Icon(Remix.bank_card_line),
      activeColor: Colors.pink,
      contentPadding: EdgeInsets.zero,
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
                  color: Colors.black26,
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
                  fontFamily: 'Poppins', 
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle
                        ),
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
                      const Icon(Remix.verified_badge_fill, color: Colors.blue, size: 24),
                    ],
                  ),
                  const Divider(height: 40),
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
                  const SizedBox(height: 100), 
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