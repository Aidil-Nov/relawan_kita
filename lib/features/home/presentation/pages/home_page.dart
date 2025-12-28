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
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/donation/presentation/pages/donation_detail_page.dart';
import 'transparency_detail_page.dart'; // Pastikan path ini benar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE VARIABLES ---
  int _selectedIndex = 0;

  // State untuk Data API
  List<CampaignModel> _campaigns = [];
  bool _isLoadingCampaigns = true;
  String _errorMessage = '';

  // Data Simulasi Dashboard
  final String _location = "Pontianak, Kalimantan Barat";
  final String _disasterStatus = "WASPADA BANJIR";
  final Color _statusColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns(); // Ambil data dari Laravel saat aplikasi dibuka
  }

  // Fungsi Fetch Data ke Laravel
  void _fetchCampaigns() async {
    try {
      final data = await ApiService().getCampaigns();
      if (mounted) {
        setState(() {
          _campaigns = data;
          _isLoadingCampaigns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCampaigns = false;
          _errorMessage =
              "Gagal memuat data donasi. Pastikan server Laravel aktif.";
        });
        debugPrint("API Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DAFTAR HALAMAN BOTTOM NAV ---
    final List<Widget> pages = [
      _buildHomeContent(), // Index 0: Dashboard
      const MapPageReal(), // Index 1: Peta
      const HistoryPage(), // Index 2: Riwayat
      const ProfilePage(), // Index 3: Profil
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          pages[_selectedIndex], // Tampilkan halaman sesuai index yang dipilih
      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
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

            // 3. Tombol Emergency (Aksi Cepat)
            Text(
              "Aksi Cepat",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildEmergencyButton(context),
            const SizedBox(height: 24),

            // 4. Grid Menu Utama
            _buildMenuGrid(),
            const SizedBox(height: 24),

            // 5. List Donasi Mendesak (DARI API LARAVEL)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Donasi Mendesak",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DonationPage(),
                      ),
                    );
                  },
                  child: const Text("Lihat Semua"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildCampaignList(), // List Data API

            const SizedBox(height: 24),

            // 6. Transparansi Bantuan (Hardcoded Dummy)
            Text(
              "Transparansi Bantuan Terkini",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            const SizedBox(height: 80), // Spacer bawah
          ],
        ),
      ),
    );
  }

  // --- WIDGET LIST CAMPAIGN (DARI API) ---
  Widget _buildCampaignList() {
    if (_isLoadingCampaigns) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Remix.error_warning_line, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: _fetchCampaigns,
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    if (_campaigns.isEmpty) {
      return const Center(child: Text("Belum ada penggalangan dana aktif."));
    }

    // Tampilkan 3 item teratas saja di Home
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _campaigns.length > 3 ? 3 : _campaigns.length,
      itemBuilder: (context, index) {
        return _campaignCard(_campaigns[index]);
      },
    );
  }

  Widget _campaignCard(CampaignModel item) {
    // Hitung progress bar
    double progress = item.collectedAmount / item.targetAmount;
    if (progress > 1.0) progress = 1.0;

    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail Donasi dengan Data API
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailPage(
              title: item.title,
              imageUrl: item.imageUrl,
              collected: item.collectedAmount / 1000000, // Konversi ke Juta
              target: item.targetAmount / 1000000,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                item.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Remix.image_2_fill, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Oleh ${item.organizer}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[200],
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Terkumpul",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        "Rp ${item.collectedAmount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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

  // --- WIDGET HEADER & STATUS ---

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
                const Icon(
                  Remix.map_pin_2_fill,
                  color: Colors.blueAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _location,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
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
              child: const Icon(
                Remix.pulse_fill,
                color: Colors.white,
                size: 30,
              ),
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

  // --- GRID MENU ---
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
          setState(() => _selectedIndex = 1); // Pindah ke Tab Peta
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

  // --- LIVE FEED ITEM ---
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
                const Icon(
                  Remix.checkbox_circle_fill,
                  color: Colors.green,
                  size: 24,
                ),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Remix.arrow_right_s_line,
                      size: 16,
                      color: Colors.grey,
                    ),
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
