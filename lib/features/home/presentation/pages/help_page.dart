import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
          _faqItem("Bagaimana cara melapor?", "Klik menu Lapor di halaman utama, isi data kejadian dan foto."),
          _faqItem("Apakah donasi kena potongan?", "Tidak, 100% donasi disalurkan."),
          const SizedBox(height: 20),
          const Text("Hubungi Kami", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Remix.whatsapp_line, color: Colors.green),
            title: const Text("WhatsApp Admin"),
            subtitle: const Text("0812-3456-7890"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Remix.mail_line, color: Colors.blue),
            title: const Text("Email Support"),
            subtitle: const Text("help@relawankita.id"),
            onTap: () {},
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
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(a),
          )
        ],
      ),
    );
  }
}