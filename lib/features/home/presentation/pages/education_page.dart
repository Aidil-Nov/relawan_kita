import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; // <--- IMPORT REMIX ICON
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // <--- IMPORT YOUTUBE PLAYER

// Import Halaman Detail
import 'education_detail_page.dart';

// Kita ubah jadi StatefulWidget agar bisa memutar Video
class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // ID Video Edukasi Gempa (BNPB)
    const String videoId = 'tJ5u_9tT-cE'; 
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edukasi Bencana",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Tombol back pakai Remix Icon
        // leading: IconButton(icon: Icon(Remix.arrow_left_line), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Cari panduan (misal: Gempa)",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Remix.search_line, color: Colors.grey), // Icon Remix
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Judul Kategori
          Text(
            "Panduan Keselamatan",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 10),
          
          // --- 1. MENU GEMPA BUMI ---
          _buildEduCard(
            context,
            "Apa yang harus dilakukan saat Gempa?",
            "Panduan evakuasi mandiri & titik kumpul.",
            Remix.earthquake_fill, // Icon Gempa
            Colors.orange,
            // ISI MATERI GEMPA:
            "1. JANGAN PANIK. Tetap tenang dan waspada.\n\n"
            "2. DROP, COVER, HOLD ON: Menunduk, berlindung di bawah meja yang kuat, dan pegang kaki meja agar tidak bergeser.\n\n"
            "3. JAUHI KACA: Hindari jendela, cermin, dan lemari kaca yang bisa pecah dan melukai Anda.\n\n"
            "4. JIKA DI LUAR RUANGAN: Cari tempat terbuka, jauhi gedung tinggi, pohon besar, papan reklame, dan tiang listrik.\n\n"
            "5. SETELAH GEMPA BERHENTI: Segera keluar menuju titik kumpul evakuasi. Jangan gunakan lift, gunakan tangga darurat."
          ),

          // --- 2. MENU P3K LUKA BAKAR ---
          _buildEduCard(
            context,
            "P3K Dasar untuk Luka Bakar",
            "Penanganan pertama sebelum medis datang.",
            Remix.first_aid_kit_fill, // Icon P3K
            Colors.red,
            // ISI MATERI P3K:
            "1. DINGINKAN: Segera aliri area luka dengan air mengalir (suhu ruangan) selama 10-20 menit. JANGAN gunakan air es atau air panas.\n\n"
            "2. LEPASKAN AKSESORIS: Segera lepaskan cincin, jam tangan, atau gelang di sekitar luka sebelum area tersebut membengkak.\n\n"
            "3. TUTUP LUKA: Gunakan kassa steril atau kain bersih yang lembab untuk menutup luka. Jangan gunakan kapas karena seratnya bisa menempel.\n\n"
            "4. JANGAN OLESKAN: Hindari mengoleskan pasta gigi, mentega, kecap, atau minyak pada luka bakar baru karena dapat memicu infeksi.\n\n"
            "5. KE DOKTER: Jika luka bakar luas, mengenai wajah, atau melepuh parah, segera bawa ke IGD terdekat."
          ),

          // --- 3. MENU TAS SIAGA BENCANA ---
          _buildEduCard(
            context,
            "Tas Siaga Bencana (Emergency Kit)",
            "Daftar barang wajib bawa saat evakuasi.",
            Remix.briefcase_4_fill, // Icon Tas/Koper
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
          Text(
            "Video Edukasi", 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)
          ),
          const SizedBox(height: 10),
          
          // VIDEO PLAYER YOUTUBE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
              progressColors: const ProgressBarColors(
                playedColor: Colors.blueAccent,
                handleColor: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "Simulasi Siaga Bencana (Sumber: BNPB)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildEduCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String detailContent) {
    return Card(
      elevation: 0, // Flat design biar modern
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200), // Border halus
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title, 
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, fontSize: 14
          )
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle, 
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)
          ),
        ),
        trailing: const Icon(Remix.arrow_right_s_line, size: 20, color: Colors.grey), // Icon Panah Remix
        
        // NAVIGASI
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EducationDetailPage(
                title: title,
                icon: icon,
                color: color,
                content: detailContent,
              ),
            ),
          );
        },
      ),
    );
  }
}