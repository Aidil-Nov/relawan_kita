import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart'; // Import Login
import 'package:relawan_kita/core/services/api_service.dart';

class PanicButtonPage extends StatefulWidget {
  const PanicButtonPage({super.key});

  @override
  State<PanicButtonPage> createState() => _PanicButtonPageState();
}

class _PanicButtonPageState extends State<PanicButtonPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  int _secondsHeld = 0;
  final int _requiredSeconds = 3;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.8, upperBound: 1.0)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHolding() async {
    // [BARU] Cek Login Dulu
    bool isLogin = await ApiService().isLoggedIn();
    if (!isLogin) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Akses Ditolak"),
          content: const Text("Fitur SOS hanya untuk pengguna terdaftar demi keamanan."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginPage())), child: const Text("Login")),
          ],
        )
      );
      return;
    }

    setState(() {
      _isPressed = true;
      _secondsHeld = 0;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsHeld++);
      HapticFeedback.lightImpact();
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
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(children: [Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Remix.alarm_warning_fill, color: Colors.white, size: 40)), const SizedBox(height: 16), const Text("SOS TERKIRIM!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]),
        content: const Text("Lokasi Anda telah dikirim ke Relawan terdekat dan BNPB.\n\nTetap tenang dan cari tempat aman.", textAlign: TextAlign.center),
        actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() => _secondsHeld = 0); }, child: const Text("Tutup", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Sinyal Darurat", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)), centerTitle: true, backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Remix.arrow_left_line, color: Colors.black), onPressed: () => Navigator.pop(context))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("TEKAN & TAHAN 3 DETIK", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Text("Hanya gunakan saat kondisi gawat darurat!", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            GestureDetector(
              onTapDown: (_) => _startHolding(),
              onTapUp: (_) => _stopHolding(),
              onTapCancel: () => _stopHolding(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double scale = _isPressed ? 1.0 : _controller.value;
                  return Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1))),
                        Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Colors.redAccent, Color(0xFFD32F2F)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, spreadRadius: 5, offset: const Offset(0, 10))]), child: Center(child: _isPressed ? Text("${_requiredSeconds - _secondsHeld}", style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold)) : const Icon(Remix.alarm_warning_fill, size: 80, color: Colors.white))),
                        if (_isPressed) SizedBox(width: 220, height: 220, child: CircularProgressIndicator(value: _secondsHeld / _requiredSeconds, strokeWidth: 8, valueColor: const AlwaysStoppedAnimation<Color>(Colors.red), backgroundColor: Colors.transparent)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
            Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.symmetric(horizontal: 24), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [const Icon(Remix.information_line, color: Colors.grey), const SizedBox(width: 10), Expanded(child: Text("Lokasi GPS Anda akan otomatis dikirim bersama sinyal ini ke server pusat.", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])))])),
          ],
        ),
      ),
    );
  }
}