import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk getaran (HapticFeedback)

class PanicButtonPage extends StatefulWidget {
  const PanicButtonPage({super.key});

  @override
  State<PanicButtonPage> createState() => _PanicButtonPageState();
}

class _PanicButtonPageState extends State<PanicButtonPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Variabel untuk mendeteksi Long Press
  Timer? _timer;
  int _secondsHeld = 0;
  final int _requiredSeconds = 3; // Harus tekan 3 detik
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Animasi Berdenyut (Pulse Animation)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.8, // Ukuran minimal
      upperBound: 1.0, // Ukuran maksimal
    )..repeat(reverse: true); // Ulangi terus menerus
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHolding() {
    setState(() {
      _isPressed = true;
      _secondsHeld = 0;
    });
    
    // Timer hitung mundur
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsHeld++;
      });
      HapticFeedback.lightImpact(); // Getar ringan tiap detik
      
      if (_secondsHeld >= _requiredSeconds) {
        _triggerSOS();
        timer.cancel();
      }
    });
  }

  void _stopHolding() {
    if (_timer != null) _timer!.cancel();
    setState(() {
      _isPressed = false;
      _secondsHeld = 0;
    });
  }

  void _triggerSOS() {
    HapticFeedback.heavyImpact(); // Getar kuat saat terkirim
    // Tampilkan dialog konfirmasi atau kirim data ke backend
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: const Text("SOS TERKIRIM!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text(
          "Lokasi Anda telah dikirim ke Relawan terdekat dan BNPB.\n\nTetap tenang dan cari tempat aman.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              setState(() => _secondsHeld = 0); // Reset
            },
            child: const Text("Tutup", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Sinyal Darurat"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "TEKAN & TAHAN 3 DETIK",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hanya gunakan saat kondisi gawat darurat!",
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 50),

            // WIDGET TOMBOL UTAMA
            GestureDetector(
              onTapDown: (_) => _startHolding(),
              onTapUp: (_) => _stopHolding(),
              onTapCancel: () => _stopHolding(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Jika sedang ditekan, hentikan animasi pulse, fokus ke progress
                  double scale = _isPressed ? 1.0 : _controller.value;
                  
                  return Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Efek Bayangan/Glow
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.2),
                          ),
                        ),
                        // Tombol Utama
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.redAccent, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Center(
                            child: _isPressed
                                ? Text(
                                    "${_requiredSeconds - _secondsHeld}", // Hitung mundur
                                    style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold),
                                  )
                                : const Icon(Icons.sos, size: 80, color: Colors.white),
                          ),
                        ),
                        // Indikator Progress Lingkaran
                        if (_isPressed)
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              value: _secondsHeld / _requiredSeconds,
                              strokeWidth: 8,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
             // Info Tambahan Aksesibilitas
             Container(
               padding: const EdgeInsets.all(16),
               margin: const EdgeInsets.symmetric(horizontal: 24),
               decoration: BoxDecoration(
                 color: Colors.grey[100],
                 borderRadius: BorderRadius.circular(12)
               ),
               child: Row(
                 children: const [
                   Icon(Icons.info_outline, color: Colors.blueGrey),
                   SizedBox(width: 10),
                   Expanded(child: Text("Lokasi GPS Anda akan otomatis dikirim bersama sinyal ini."))
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}