import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// --- IMPORTS HALAMAN LAIN ---
import 'package:relawan_kita/features/emergency/presentation/pages/report_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/history_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/notification_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/education_page.dart';
import 'package:relawan_kita/features/disaster_map/presentation/pages/map_page_real.dart';
import 'package:relawan_kita/core/presentation/pages/dummy_pages.dart';
import 'package:relawan_kita/features/emergency/presentation/pages/panic_button_page.dart';
import 'transparency_detail_page.dart'; // Pastikan path ini benar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE VARIABLES ---
  int _selectedIndex = 0;

  // Data Simulasi
  final String _location = "Pontianak, Kalimantan Barat";
  final String _disasterStatus = "WASPADA BANJIR";
  final Color _statusColor = Colors.orange;

  // HAPUS LIST _pages DARI SINI
  // HAPUS initState()

  @override
  Widget build(BuildContext context) {
    // --- SOLUSI: DEFINISIKAN HALAMAN DI SINI (DALAM BUILD) ---
    // Ini aman karena 'context' sudah tersedia di dalam build()
    final List<Widget> pages = [
      _buildHomeContent(), // Halaman 0: Home (Dashboard)
      const MapPageReal(), // Halaman 1: Peta
      const HistoryPage(), // Halaman 2: Riwayat
      const ProfilePage(), // Halaman 3: Profil
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Gunakan pages[_selectedIndex]
      body: pages[_selectedIndex],

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: Colors.blueAccent.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Remix.home_4_line),
            selectedIcon: Icon(Remix.home_4_fill, color: Colors.blueAccent),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Remix.map_2_line),
            selectedIcon: Icon(Remix.map_2_fill, color: Colors.blueAccent),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Remix.history_line),
            selectedIcon: Icon(Remix.history_fill, color: Colors.blueAccent),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Remix.user_3_line),
            selectedIcon: Icon(Remix.user_3_fill, color: Colors.blueAccent),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // KONTEN DASHBOARD (HOME)
  // ===========================================================================
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            _buildHeader(),
            const SizedBox(height: 20),

            // 2. Kartu Status Bencana
            _buildStatusCard(),
            const SizedBox(height: 24),

            // 3. Tombol Emergency
            Text(
              "Aksi Cepat",
              // Error sebelumnya terjadi karena baris ini dipanggil di initState
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18), 
            ),
            const SizedBox(height: 12),
            _buildEmergencyButton(context),
            const SizedBox(height: 24),

            // 4. Grid Menu
            _buildMenuGrid(),
            const SizedBox(height: 24),

            // 5. List Transparansi
            Text(
              "Transparansi Bantuan Terkini",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildLiveFeedItem(
              "Logistik Beras 5 Ton",
              "Diterima di Posko A",
              "5 menit lalu",
            ),
            _buildLiveFeedItem(
              "Evakuasi Lansia",
              "Selesai oleh Tim SAR",
              "12 menit lalu",
            ),
            _buildLiveFeedItem(
              "Donasi Rp 50.000.000",
              "Terkumpul untuk Gempa X",
              "1 jam lalu",
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Halo, Warga!", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Remix.map_pin_2_fill, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 4),
                Text(
                  _location,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPage()),
                );
              },
              icon: const Icon(Remix.notification_3_line, size: 28),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_statusColor, _statusColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Remix.alarm_warning_fill, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Status Wilayah Anda:",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  _disasterStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Hujan deras diprediksi sore ini. Harap berhati-hati.",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PanicButtonPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Remix.pulse_fill, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DARURAT / SOS",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Tekan jika butuh pertolongan medis atau evakuasi segera.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Remix.arrow_right_s_line, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _menuItem(Remix.hand_heart_fill, "Donasi", Colors.pink, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DonationPage()),
          );
        }),
        _menuItem(Remix.megaphone_fill, "Lapor", Colors.blue, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPage()),
          );
        }),
        _menuItem(Remix.map_fill, "Peta", Colors.green, () {
          setState(() => _selectedIndex = 1);
        }),
        _menuItem(Remix.book_read_fill, "Edukasi", Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EducationPage()),
          );
        }),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFeedItem(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransparencyDetailPage(
                  title: title,
                  subtitle: subtitle,
                  time: time,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Remix.checkbox_circle_fill, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 4),
                    const Icon(Remix.arrow_right_s_line, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}