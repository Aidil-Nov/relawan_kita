import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // Fungsi Simulasi Buka Aplikasi Lain
  void _launchApp(BuildContext context, String appName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Remix.loader_4_line, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text("Membuka $appName..."),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("FAQ (Pertanyaan Umum)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _faqItem("Bagaimana cara melapor?", "Klik menu Lapor di halaman utama, pilih kategori bencana, ambil foto bukti, dan isi deskripsi kejadian. Pastikan GPS aktif."),
          _faqItem("Apakah donasi kena potongan?", "Platform RelawanKita tidak mengambil potongan administrasi. Namun, potongan biaya transfer bank/e-wallet mungkin berlaku."),
          _faqItem("Bagaimana cara jadi relawan?", "Lengkapi profil Anda, upload sertifikat kompetensi di menu Sertifikasi, lalu tunggu verifikasi dari admin."),
          
          const SizedBox(height: 30),
          
          const Text("Hubungi Kami", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Remix.whatsapp_line, color: Colors.green),
            title: const Text("WhatsApp Admin"),
            subtitle: const Text("0812-3456-7890"),
            trailing: const Icon(Remix.external_link_line, size: 16),
            onTap: () => _launchApp(context, "WhatsApp"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Remix.mail_line, color: Colors.blue),
            title: const Text("Email Support"),
            subtitle: const Text("help@relawankita.id"),
            trailing: const Icon(Remix.external_link_line, size: 16),
            onTap: () => _launchApp(context, "Aplikasi Email"),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(a, style: TextStyle(color: Colors.grey[700])),
          )
        ],
      ),
    );
  }
}