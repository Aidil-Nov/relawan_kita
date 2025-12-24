import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pusat Bantuan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pertanyaan Umum (FAQ)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Item 1
            _buildFAQItem(
              "Bagaimana cara verifikasi akun relawan?",
              "Anda harus mengunggah foto KTP dan foto selfie di menu Edit Profil. Data akan diverifikasi manual oleh Admin dalam 1x24 jam."
            ),
            // Item 2
            _buildFAQItem(
              "Apakah donasi saya terkena potongan?",
              "Tidak. RelawanKita menjamin 100% donasi disalurkan tanpa potongan biaya administrasi platform."
            ),
            // Item 3
            _buildFAQItem(
              "Tombol SOS tidak berfungsi?",
              "Pastikan Anda telah memberikan izin akses Lokasi (GPS) pada pengaturan HP Anda agar titik koordinat bisa terbaca."
            ),

            const SizedBox(height: 30),
            const Text("Hubungi Kami", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.chat, color: Colors.white)),
              title: const Text("WhatsApp Admin"),
              subtitle: const Text("0812-3456-7890 (24 Jam)"),
              onTap: () {
                // Simulasi Buka WA
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membuka WhatsApp...")));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
            ),
            const SizedBox(height: 10),
             ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.email, color: Colors.white)),
              title: const Text("Email Support"),
              subtitle: const Text("bantuan@relawankita.go.id"),
              onTap: () {},
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: TextStyle(color: Colors.grey[700])),
          )
        ],
      ),
    );
  }
}