import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; 
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; 

// Pastikan file ini ada di project Anda
import 'education_detail_page.dart';

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
    
    // --- ID VIDEO DIGANTI DISINI ---
    // Video: "Modul Manajemen Bencana 1: Animasi Pencegahan & Mitigasi" (BNPB Indonesia)
    // ID ini dipilih karena merupakan materi modul resmi yang aman untuk aplikasi publik.
    const String videoId = 'ka1Xry3T3Os'; 
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,      // Penting: False agar tidak menghabiskan kuota user otomatis
        mute: false,
        enableCaption: true,  // Aksesibilitas
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    // Best Practice: Matikan controller saat halaman ditutup untuk mencegah memory leak
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background sedikit abu agar card lebih pop-up
      appBar: AppBar(
        title: Text(
          "Edukasi Bencana",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SEARCH BAR ---
          TextField(
            decoration: InputDecoration(
              hintText: "Cari panduan (misal: Gempa)",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Remix.search_line, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none, // Hilangkan border default
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // --- SECTION VIDEO PLAYER ---
          Text(
            "Video Edukasi Terkini", 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 12),
          
          // Container Video dengan Dekorasi
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9, // Rasio standar Youtube agar layout tidak bergeser
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueAccent,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.blueAccent,
                    handleColor: Colors.blueAccent,
                  ),
                  onReady: () {
                    print('Player is ready.');
                  },
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                "Modul Animasi: Mitigasi Bencana (BNPB)", // Judul disesuaikan dengan video baru
                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION PANDUAN KESELAMATAN ---
          Text(
            "Panduan Keselamatan",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 12),
          
          // 1. MENU GEMPA BUMI
          _buildEduCard(
            context,
            "Apa yang harus dilakukan saat Gempa?",
            "Panduan evakuasi mandiri & titik kumpul.",
            Remix.earthquake_fill, 
            Colors.orange,
            // ISI MATERI
            "1. JANGAN PANIK. Tetap tenang dan waspada.\n\n"
            "2. DROP, COVER, HOLD ON: Menunduk, berlindung di bawah meja yang kuat.\n\n"
            "3. JAUHI KACA: Hindari jendela dan cermin.\n\n"
            "4. TITIK KUMPUL: Segera menuju area terbuka setelah guncangan berhenti."
          ),

          // 2. MENU P3K LUKA BAKAR
          _buildEduCard(
            context,
            "P3K Dasar untuk Luka Bakar",
            "Penanganan pertama sebelum medis datang.",
            Remix.first_aid_kit_fill,
            Colors.red,
            // ISI MATERI
            "1. DINGINKAN: Aliri air mengalir 10-20 menit.\n\n"
            "2. LEPASKAN AKSESORIS: Cincin atau jam tangan.\n\n"
            "3. TUTUP LUKA: Gunakan kassa steril lembab.\n\n"
            "4. JANGAN OLESKAN: Hindari pasta gigi atau mentega."
          ),

          // 3. MENU TAS SIAGA BENCANA
          _buildEduCard(
            context,
            "Tas Siaga Bencana (Emergency Kit)",
            "Daftar barang wajib bawa saat evakuasi.",
            Remix.briefcase_4_fill,
            Colors.blue,
            // ISI MATERI
            "✅ DOKUMEN PENTING (KTP, KK, Surat Tanah).\n\n"
            "✅ MAKANAN & MINUMAN (3 Hari).\n\n"
            "✅ PAKAIAN & SELIMUT.\n\n"
            "✅ OBAT-OBATAN & P3K.\n\n"
            "✅ SENTER & PELUIT SOS."
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET HELPER (Card Menu) ---
  Widget _buildEduCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String detailContent) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell( // Menggunakan InkWell untuk efek sentuhan (ripple effect)
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke Halaman Detail
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 14
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle, 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])
                    ),
                  ],
                ),
              ),
              Icon(Remix.arrow_right_s_line, size: 24, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}