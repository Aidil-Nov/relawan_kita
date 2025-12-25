import 'package:flutter/material.dart';
import 'package:relawan_kita/features/donation/presentation/pages/donation_detail_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/settings_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/certificate_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/help_page.dart';

// 1. HALAMAN PETA (Simulasi Sebaran Bencana)
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Peta (Warna Alam)
          Container(color: const Color(0xFFE0E0E0)), // Abu-abu jalanan
          // Simulasi Area Hijau/Taman
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(color: Colors.green[100]),
          ),

          // Simulasi Sungai/Laut
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(color: Colors.lightBlue[100]),
          ),

          // PIN LOKASI (Titik Bencana & Posko)
          _buildPin(100, 50, Colors.red, "Banjir"), // Titik Merah (Bahaya)
          _buildPin(250, 150, Colors.red, "Longsor"),
          _buildPin(400, 80, Colors.blue, "Posko 1"), // Titik Biru (Aman)
          _buildPin(500, 300, Colors.blue, "Dapur Umum"),

          // Floating Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    "Cari lokasi posko...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildPin(double top, double left, Color color, String label) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Icon(Icons.location_on, color: color, size: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. HALAMAN DONASI (Crowdfunding Style)
class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Galang Dana Bencana")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDonationCard(
            context,
            "Banjir Bandang Demak",
            "assets/images/banjir.jpg",
            150,
            200,
          ),
          const SizedBox(height: 16),
          _buildDonationCard(
            context,
            "Gempa Cianjur Recovery",
            "assets/images/gempa.jpg",
            500,
            1000,
          ),
          const SizedBox(height: 16),
          _buildDonationCard(
            context,
            "Posko Dapur Umum",
            "assets/images/posko.jpg",
            20,
            100,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(
    BuildContext context,
    String title,
    String imgPath,
    double collected,
    double target,
  ) {
    double progress = collected / target;
    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailPage(
              title: title,
              imageUrl: imgPath,
              collected: collected,
              target: target,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Aset (Bukan Placeholder lagi)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                imgPath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(
                  // Fallback jika gambar error
                  height: 150,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.pink,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Terkumpul: ${collected.toInt()}jt",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        "Target: ${target.toInt()}jt",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

// 3. HALAMAN PROFIL (E-Gov Digital ID Style)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER BACKGROUND
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Kartu Tanda Relawan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Terverifikasi BNPB",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // ID CARD CONTAINER (Menumpuk di atas Header)
            Transform.translate(
              offset: const Offset(0, -80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // KARTU DIGITAL
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // FOTO PROFIL
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 3,
                                  ),
                                  // Ganti dengan NetworkImage atau Asset jika ada
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      "https://i.pravatar.cc/300",
                                    ), // Avatar Random
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // TEXT INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Budi Santoso",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Relawan Medis & Logistik",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "NIK: 6171032508900001",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),

                          // QR CODE AREA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Scan ID di Posko",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "ID: REL-JKT-8821",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              // Simulasi QR Code dengan Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.qr_code_2, size: 60),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // MENU PENGATURAN
                    // ... di dalam ProfilePage ...

                    // 1. Menu Sertifikat
                    _buildProfileMenu(Icons.badge, "Sertifikat Pelatihan", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CertificatePage(),
                        ),
                      );
                    }),

                    // 2. Menu Pengaturan (Sudah ada sebelumnya)
                    _buildProfileMenu(
                      Icons.settings,
                      "Pengaturan Aplikasi",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),

                    // 3. Menu Bantuan
                    _buildProfileMenu(
                      Icons.help_outline,
                      "Bantuan & Dukungan",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // TOMBOL LOGOUT
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          "Keluar Akun",
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
