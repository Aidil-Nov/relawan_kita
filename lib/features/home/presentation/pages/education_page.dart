import 'package:flutter/material.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edukasi Bencana")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Cari panduan (misal: Gempa)",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 20),

          // Kategori
          const Text("Panduan Keselamatan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          _buildEduCard(
            "Apa yang harus dilakukan saat Gempa?",
            "Panduan evakuasi mandiri & titik kumpul.",
            Icons.vibration,
            Colors.orange,
          ),
          _buildEduCard(
            "P3K Dasar untuk Luka Bakar",
            "Penanganan pertama sebelum medis datang.",
            Icons.medical_services,
            Colors.red,
          ),
          _buildEduCard(
            "Tas Siaga Bencana (Emergency Kit)",
            "Daftar barang wajib bawa saat evakuasi.",
            Icons.backpack,
            Colors.blue,
          ),
          
          const SizedBox(height: 20),
          const Text("Video Edukasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Placeholder Video
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.play_circle_fill, size: 50, color: Colors.blueAccent),
                  SizedBox(height: 8),
                  Text("Simulasi Banjir 2024"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEduCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          // Nanti navigasi ke detail artikel (DetailEducationPage)
        },
      ),
    );
  }
}