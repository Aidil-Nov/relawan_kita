import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk fitur copy ke clipboard
import 'package:remixicon/remixicon.dart'; // Pastikan package ini ada

class PaymentWaitingPage extends StatefulWidget {
  final String amount;
  final String method;

  const PaymentWaitingPage({
    super.key,
    required this.amount,
    required this.method,
  });

  @override
  State<PaymentWaitingPage> createState() => _PaymentWaitingPageState();
}

class _PaymentWaitingPageState extends State<PaymentWaitingPage> {
  // Timer Mundur (Simulasi 24 Jam)
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 23, minutes: 59, seconds: 59);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format Tampilan Waktu (HH:MM:SS)
    String formattedTime = 
      "${_timeLeft.inHours.toString().padLeft(2, '0')}:"
      "${(_timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:"
      "${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}";

    // Data Mockup Virtual Account (Sesuai metode yang dipilih)
    String vaNumber = "880123456789"; 
    String bankName = widget.method.toUpperCase();
    
    // Logika tampilan jika metode pembayaran GoPay
    bool isQris = widget.method == 'gopay';
    if(isQris) { 
      bankName = "GOPAY / QRIS";
      vaNumber = "Scan QR Code di bawah"; 
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Menunggu Pembayaran"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // User tidak boleh back sembarangan
        actions: [
          IconButton(
            icon: const Icon(Remix.close_line, color: Colors.black),
            onPressed: () => Navigator.pop(context), // Tombol X untuk batal/keluar
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Timer Countdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Remix.time_line, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text(
                    "Selesaikan dalam $formattedTime",
                    style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Info Detail Pembayaran
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
              ),
              child: Column(
                children: [
                  Text("Total Pembayaran", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    "Rp ${widget.amount}", 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const Divider(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Metode Bayar", style: TextStyle(color: Colors.grey[600])),
                      Text(bankName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // TAMPILAN NOMOR VA ATAU QR CODE
                  if (isQris) 
                    // Tampilan QRIS
                    Container(
                      height: 180, width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: const Center(
                        child: Icon(Remix.qr_code_line, size: 120, color: Colors.black),
                      ),
                    )
                  else
                    // Tampilan Virtual Account
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nomor Virtual Account", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                vaNumber, 
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.blue[800], 
                                  letterSpacing: 1
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Fitur Copy to Clipboard
                                  Clipboard.setData(ClipboardData(text: vaNumber));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Nomor VA berhasil disalin!"))
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text("SALIN", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 4),
                                    Icon(Remix.file_copy_line, color: Colors.blue, size: 18),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 3. Tombol Aksi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showSuccessDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text("SAYA SUDAH MEMBAYAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                 // Kembali ke halaman detail donasi (Batal/Nanti Saja)
                 Navigator.pop(context); 
              },
              child: const Text("Cek Status Pembayaran Nanti"),
            )
          ],
        ),
      ),
    );
  }

  // DIALOG SUKSES
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Remix.checkbox_circle_fill, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text("Pembayaran Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Terima kasih atas bantuan Anda. Donasi telah terverifikasi oleh sistem.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context); // Tutup Page Waiting
              Navigator.pop(context); // Tutup Page Detail (Kembali ke List Donasi)
            }, 
            child: const Text("Selesai", style: TextStyle(fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }
}