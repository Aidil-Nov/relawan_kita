import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String snapToken;

  const MidtransPaymentPage({super.key, required this.snapToken});

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // URL Sandbox Midtrans (Mode Test)
    // Jika nanti mau Production (Asli), hapus ".sandbox" dari URL
    final String paymentUrl = "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // Jika pembayaran selesai, Midtrans biasanya redirect ke URL tertentu
            // Kita bisa tangkap di sini kalau mau auto-close
            if (request.url.contains('status_code=200') || request.url.contains('transaction_status=settlement')) {
              Navigator.pop(context, true); // Kembali dengan hasil SUKSES
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Tampilkan dialog konfirmasi jika user mau batal
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Batalkan Pembayaran?"),
                content: const Text("Transaksi belum selesai. Apakah Anda yakin ingin keluar?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Lanjut Bayar")),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Tutup Dialog
                      Navigator.pop(context); // Tutup Halaman Payment
                    }, 
                    child: const Text("Keluar", style: TextStyle(color: Colors.red))
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}