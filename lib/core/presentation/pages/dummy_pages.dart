import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// --- IMPORTS UNTUK NAVIGASI ---
// Pastikan path ini sesuai dengan struktur folder Anda
import 'package:relawan_kita/features/donation/presentation/pages/donation_detail_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/edit_profile_page.dart'; // File yg Anda upload
import 'package:relawan_kita/features/auth/presentation/pages/certificate_page.dart'; // File yg Anda upload
import 'package:relawan_kita/features/home/presentation/pages/settings_page.dart'; // Kita buat di bawah
import 'package:relawan_kita/features/home/presentation/pages/help_page.dart'; // Kita buat di bawah

// ============================================================================
// 1. DONATION PAGE (Halaman List Donasi)
// ============================================================================
class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Galang Dana",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Ajakan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.pink.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Remix.hand_heart_fill, color: Colors.pink, size: 40),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Bantuan Anda sangat berarti bagi mereka yang terdampak.",
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // List Donasi
          _buildDonationItem(
            context,
            title: "Banjir Bandang Demak",
            organizer: "BPBD Demak",
            image:
                "assets/images/banjir.jpg", // Pastikan aset ada atau ganti NetworkImage
            collected: 150,
            target: 500,
          ),
          _buildDonationItem(
            context,
            title: "Gempa Bumi Cianjur",
            organizer: "Relawan Kita Pusat",
            image: "assets/images/gempa.jpg",
            collected: 890,
            target: 1000,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationItem(
    BuildContext context, {
    required String title,
    required String organizer,
    required String image,
    required double collected,
    required double target,
  }) {
    // Progress
    double progress = collected / target;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigasi ke Detail Donasi
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailPage(
                title: title,
                imageUrl: image,
                collected: collected,
                target: target,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300], // Placeholder warna
                // child: Image.asset(image, fit: BoxFit.cover), // Gunakan ini jika aset siap
                child: const Icon(
                  Remix.image_line,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Remix.verified_badge_fill,
                        color: Colors.blue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        organizer,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.pink,
                    backgroundColor: Colors.pink[50],
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Terkumpul: Rp ${collected.toInt()}jt",
                        style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Target: Rp ${target.toInt()}jt",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. PROFILE PAGE (Halaman Profil Pengguna)
// ============================================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Saya"),
        centerTitle: false,
        automaticallyImplyLeading: false, // Hilangkan tombol back di tab menu
        actions: [
          // ... di dalam ProfilePage ...
          IconButton(
            icon: const Icon(Remix.logout_box_r_line, color: Colors.red),
            onPressed: () {
              // TAMPILKAN DIALOG KONFIRMASI
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Keluar"),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar dari akun ini?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Batal
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                        Navigator.pushReplacementNamed(
                          context,
                          '/login',
                        ); // Pindah ke Login
                      },
                      child: const Text(
                        "Ya, Keluar",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // ...
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER PROFIL
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  Remix.user_smile_line,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Budi Santoso",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Relawan Siaga - Pontianak",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // MENU OPTIONS
            _buildProfileMenu(
              context,
              icon: Remix.user_settings_line,
              text: "Edit Profil",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              ),
            ),
            _buildProfileMenu(
              context,
              icon: Remix.medal_line,
              text: "Sertifikat Kompetensi",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CertificatePage(),
                ),
              ),
            ),
            _buildProfileMenu(
              context,
              icon: Remix.settings_3_line,
              text: "Pengaturan",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ),
            ),
            _buildProfileMenu(
              context,
              icon: Remix.question_line,
              text: "Pusat Bantuan",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Remix.arrow_right_s_line, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
