import 'package:flutter/material.dart';
import 'package:relawan_kita/features/emergency/presentation/pages/report_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/history_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/notification_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/education_page.dart';
import 'package:relawan_kita/features/disaster_map/presentation/pages/map_page_real.dart';
// --- IMPORTS ---
// Pastikan path ini sesuai dengan struktur folder Anda
import 'package:relawan_kita/core/presentation/pages/dummy_pages.dart';
import 'package:relawan_kita/features/emergency/presentation/pages/panic_button_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE VARIABLES ---
  int _selectedIndex = 0; // Index aktif untuk BottomNavigationBar

  // Data Simulasi (Nanti bisa diganti dengan data dari API/Backend)
  final String _location = "Pontianak, Kalimantan Barat";
  final String _disasterStatus = "WASPADA BANJIR";
  final Color _statusColor = Colors.orange;

  // Daftar Halaman untuk Navigasi Bawah
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman
    _pages = [
      _buildHomeContent(),
      const MapPageReal(),
      const HistoryPage(), // <-- Sudah diganti
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // LOGIKA SWITCHING HALAMAN (Jantung Navigasi)
      body: _pages[_selectedIndex],

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: Colors.blueAccent.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_filled, color: Colors.blueAccent),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Colors.blueAccent),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Colors.blueAccent),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.blueAccent),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BAGIAN 1: KONTEN DASHBOARD (HOME)
  // ===========================================================================
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Lokasi & Notif)
            _buildHeader(),
            const SizedBox(height: 20),

            // 2. Kartu Status Bencana (E-Gov Info)
            _buildStatusCard(),
            const SizedBox(height: 24),

            // 3. Tombol Emergency (Akses Cepat)
            const Text(
              "Aksi Cepat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildEmergencyButton(context),
            const SizedBox(height: 24),

            // 4. Grid Menu (Navigasi Fitur Lain)
            _buildMenuGrid(),
            const SizedBox(height: 24),

            // 5. List Transparansi (Social Proof)
            const Text(
              "Transparansi Bantuan Terkini",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            const SizedBox(
              height: 80,
            ), // Padding bawah agar tidak tertutup navbar
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BAGIAN 2: WIDGET-WIDGET PENDUKUNG (UI COMPONENTS)
  // ===========================================================================

  // HEADER: Menampilkan Lokasi & Profil Singkat
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Halo, Warga!",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blueAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _location,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                // NAVIGASI KE NOTIFIKASI
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_outlined, size: 28),
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

  // STATUS CARD: Informasi E-Gov Realtime
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
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 40,
          ),
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

  // EMERGENCY BUTTON: Link ke Panic Button
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
              child: const Icon(Icons.sos, color: Colors.white, size: 30),
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
            const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
          ],
        ),
      ),
    );
  }

  // MENU GRID: Navigasi Ikon Utama
  Widget _buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Tombol DONASI -> Ke Halaman List Donasi
        _menuItem(Icons.volunteer_activism, "Donasi", Colors.pink, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DonationPage(),
            ), // Pastikan DonationPage di-import
          );
        }),

        // 2. Tombol LAPOR -> Ke Halaman Form Laporan
        _menuItem(Icons.assignment_add, "Lapor", Colors.blue, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportPage(),
            ), // Pastikan ReportPage di-import
          );
        }),

        // 3. Tombol PETA -> Pindah ke Tab Peta (Index 1)
        _menuItem(Icons.map, "Peta", Colors.green, () {
          setState(() {
            _selectedIndex =
                1; // Mengubah state agar tab bawah pindah ke "Peta"
          });
        }),

        // 4. Tombol EDUKASI -> Placeholder (Belum ada halaman)
        _menuItem(Icons.menu_book, "Edukasi", Colors.purple, () {
          // NAVIGASI KE EDUKASI
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EducationPage()),
          );
        }),
      ],
    );
  }

  // ITEM MENU (Helper untuk _buildMenuGrid)
  Widget _menuItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
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

  // LIST ITEM: Transparansi Bantuan
  Widget _buildLiveFeedItem(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
