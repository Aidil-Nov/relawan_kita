import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart'; // Import Wajib

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // --- FUNGSI BUKA WHATSAPP ---
  Future<void> _launchWhatsApp(BuildContext context) async {
    // Nomor HP (Ganti 08 dengan 62)
    // Format: 6285787275199
    const String phoneNumber = "6285787275199"; 
    const String message = "Halo Admin RelawanKita, saya butuh bantuan.";
    
    // URL Scheme WhatsApp
    final Uri url = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka WhatsApp atau aplikasi tidak terinstall.")),
        );
      }
    }
  }

  // --- FUNGSI BUKA EMAIL ---
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'aidilnovelinfitrah237@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Bantuan Aplikasi RelawanKita',
        'body': 'Halo Support Team, saya ingin bertanya tentang...',
      }),
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka aplikasi Email.")),
        );
      }
    }
  }

  // Helper untuk encode spasi/karakter khusus di email
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pusat Bantuan"),
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "FAQ (Pertanyaan Umum)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _faqItem(
            "Bagaimana cara melapor?",
            "Klik menu Lapor di halaman utama, pilih kategori bencana, ambil foto bukti, dan isi deskripsi kejadian. Pastikan GPS aktif.",
          ),
          _faqItem(
            "Apakah donasi kena potongan?",
            "Platform RelawanKita tidak mengambil potongan administrasi. Namun, potongan biaya transfer bank/e-wallet mungkin berlaku.",
          ),
          _faqItem(
            "Bagaimana cara reset password?",
            "Masuk ke menu Pengaturan di halaman Profil, lalu pilih 'Ganti Password'.",
          ),

          const SizedBox(height: 30),

          const Text(
            "Hubungi Kami",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // TOMBOL WHATSAPP
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: const Icon(Remix.whatsapp_fill, color: Colors.green),
            ),
            title: const Text("WhatsApp Admin", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("0857-8727-5199 (Chat Only)"),
            trailing: const Icon(Remix.external_link_line, size: 16, color: Colors.grey),
            onTap: () => _launchWhatsApp(context),
          ),
          
          const Divider(),
          
          // TOMBOL EMAIL
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: const Icon(Remix.mail_fill, color: Colors.blue),
            ),
            title: const Text("Email Support", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("aidilnovelinfitrah237@gmail.com"),
            trailing: const Icon(Remix.external_link_line, size: 16, color: Colors.grey),
            onTap: () => _launchEmail(context),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200)
      ),
      child: ExpansionTile(
        title: Text(
          q,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(a, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}