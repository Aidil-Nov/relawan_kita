import 'package:flutter/material.dart';
// PENTING: Import halaman detail yang baru saja Anda buat
import 'education_detail_page.dart'; 


class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edukasi Bencana"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
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

          // Judul Kategori
          const Text("Panduan Keselamatan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // --- 1. MENU GEMPA BUMI ---
          _buildEduCard(
            context,
            "Apa yang harus dilakukan saat Gempa?",
            "Panduan evakuasi mandiri & titik kumpul.",
            Icons.vibration,
            Colors.orange,
            // ISI MATERI GEMPA:
            "1. Jangan Panik Tetap tenang dan waspada.\n\n"
            "2. DROP, COVER, HOLD ON. Menunduk, berlindung di bawah meja yang kuat, dan pegang kaki meja agar tidak bergeser.\n\n"
            "3. Hindari jendela, cermin, dan lemari kaca yang bisa pecah dan melukai Anda.\n\n"
            "4. Jika anda diluar ruangan cari tempat terbuka, jauhi gedung tinggi, pohon besar, papan reklame, dan tiang listrik.\n\n"
            "5. Setelah gempa berhenti Segera keluar menuju titik kumpul evakuasi. Jangan gunakan lift, gunakan tangga darurat."
          ),

          // --- 2. MENU P3K LUKA BAKAR ---
          _buildEduCard(
            context,
            "P3K Dasar untuk Luka Bakar",
            "Penanganan pertama sebelum medis datang.",
            Icons.medical_services,
            Colors.red,
            // ISI MATERI P3K:
            "1. Segera aliri area luka dengan air mengalir (suhu ruangan) selama 10-20 menit. JANGAN gunakan air es atau air panas.\n\n"
            "2. Segera lepaskan aksesoris anda cincin, jam tangan, atau gelang di sekitar luka sebelum area tersebut membengkak.\n\n"
            "3. Jika ada luka, tutup luka Gunakan kassa steril atau kain bersih yang lembab untuk menutup luka. Jangan gunakan kapas karena seratnya bisa menempel.\n\n"
            "4. JANGAN mengoleskan pasta gigi, mentega, kecap, atau minyak pada luka bakar baru karena dapat memicu infeksi.\n\n"
            "5. Segera ke Dokter Jika luka bakar luas, mengenai wajah, atau melepuh parah, segera bawa ke IGD terdekat."
          ),

          // --- 3. MENU TAS SIAGA BENCANA ---
          _buildEduCard(
            context,
            "Tas Siaga Bencana (Emergency Kit)",
            "Daftar barang wajib bawa saat evakuasi.",
            Icons.backpack,
            Colors.blue,
            // ISI MATERI TAS SIAGA:
            "Siapkan satu tas ransel (Go-Bag) di tempat yang mudah dijangkau, berisi:\n\n"
            "✅ DOKUMEN PENTING: Fotokopi KTP, KK, Ijazah, Sertifikat Tanah (masukkan dalam plastik kedap air).\n\n"
            "✅ MAKANAN & MINUMAN: Makanan kaleng/biskuit dan air mineral cukup untuk 3 hari.\n\n"
            "✅ PAKAIAN: Baju ganti, jaket, dan selimut hangat.\n\n"
            "✅ OBAT-OBATAN: Kotak P3K standar dan obat rutin pribadi (misal obat asma/diabetes).\n\n"
            "✅ ALAT BANTU: Senter, baterai cadangan, powerbank, peluit (untuk sinyal SOS), masker, dan hand sanitizer."
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

  // --- WIDGET HELPER UNTUK MEMBUAT KARTU MENU ---
  Widget _buildEduCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String detailContent) {
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        
        // NAVIGASI: Saat diklik, kirim data ke EducationDetailPage
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EducationDetailPage(
                title: title,
                icon: icon,
                color: color,
                content: detailContent, // Mengirim isi materi ke halaman detail
              ),
            ),
          );
        },
      ),
    );
  }
}