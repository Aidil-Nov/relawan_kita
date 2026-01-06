import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator

// --- IMPORTS HALAMAN LAIN ---
import 'package:relawan_kita/features/emergency/presentation/pages/report_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/history_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/notification_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/education_page.dart';
import 'package:relawan_kita/features/disaster_map/presentation/pages/map_page_real.dart';
import 'package:relawan_kita/features/emergency/presentation/pages/panic_button_page.dart';
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/donation/presentation/pages/donation_detail_page.dart';
import 'package:relawan_kita/features/profile/presentation/pages/profile_page.dart';
import 'transparency_detail_page.dart';
import 'package:relawan_kita/features/donation/presentation/pages/donation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<CampaignModel> _campaigns = [];
  bool _isLoadingCampaigns = true;
  String _errorMessage = '';

  String _userName = "Tamu";

  // --- VARIABEL CUACA (DINAMIS) ---
  String _location = "Mencari Lokasi...";
  String _disasterStatus = "MEMUAT DATA...";
  String _weatherDesc = "Sedang mengambil data cuaca...";
  String _temp = "--°C";
  Color _statusColor = Colors.grey;
  IconData _weatherIcon = Remix.cloud_line;

  @override
  void initState() {
    super.initState();
    _checkUser();
    _fetchCampaigns();
    _fetchWeatherData(); // [BARU] Ambil Cuaca Real-time
  }

  void _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Tamu";
    });
  }

  Future<void> _fetchCampaigns() async {
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
          _errorMessage = "Gagal memuat data donasi.";
        });
      }
    }
  }

  // --- [DIPERBAIKI] LOGIKA AMBIL CUACA ---
  Future<void> _fetchWeatherData() async {
    try {
      // Set status awal saat refresh
      setState(() {
        _location = "Mencari Lokasi...";
      });

      // 1. Cek Izin Lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _location = "Izin Lokasi Ditolak");
          return;
        }
      }

      // 2. Ambil Koordinat GPS
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 3. Panggil API ke Laravel
      final data = await ApiService().getWeather(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        if (data != null) {
          // --- SKENARIO SUKSES ---
          String cityName = data['name'];
          double temp = data['main']['temp'].toDouble();
          String weatherMain = data['weather'][0]['main']
              .toString()
              .toLowerCase();
          String description = data['weather'][0]['description'].toString();

          setState(() {
            _location = cityName;
            _temp = "${temp.toStringAsFixed(1)}°C";
            _weatherDesc =
                description[0].toUpperCase() + description.substring(1);

            // Logika Warna Status
            if (weatherMain.contains('rain') ||
                weatherMain.contains('thunderstorm') ||
                weatherMain.contains('drizzle')) {
              _disasterStatus = "WASPADA HUJAN";
              _statusColor = Colors.orange;
              _weatherIcon = Remix.showers_line;
              if (weatherMain.contains('heavy') ||
                  weatherMain.contains('extreme')) {
                _disasterStatus = "SIAGA BANJIR";
                _statusColor = Colors.red;
                _weatherIcon = Remix.thunderstorms_line;
              }
            } else if (weatherMain.contains('clear')) {
              _disasterStatus = "AMAN TERKENDALI";
              _statusColor = Colors.green;
              _weatherIcon = Remix.sun_line;
            } else {
              _disasterStatus = "BERAWAN / NORMAL";
              _statusColor = Colors.blue;
              _weatherIcon = Remix.cloudy_line;
            }
          });
        } else {
          // --- [BARU] SKENARIO ERROR (API NULL) ---
          // Ini akan memberi tahu kita jika API Key mati atau Server Error
          setState(() {
            _location = "Gagal memuat data";
            _disasterStatus = "SERVER / API ERROR";
            _weatherDesc = "Cek koneksi atau API Key";
            _statusColor = Colors.grey;
            _weatherIcon = Remix.wifi_off_line;
          });
        }
      }
    } catch (e) {
      print("Error Weather: $e");
      if (mounted) {
        setState(() {
          _location = "Error Aplikasi";
          _weatherDesc = e.toString(); // Tampilkan error asli untuk debugging
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const MapPageReal(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            _fetchCampaigns();
            _fetchWeatherData(); // Refresh cuaca juga saat tap Home
          }
        },
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

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchCampaigns();
        await _fetchWeatherData();
      },
      color: Colors.blueAccent,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatusCard(), // Kartu Status sekarang Real-time
              const SizedBox(height: 24),
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
              _buildMenuGrid(),
              const SizedBox(height: 24),
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
                      ).then((_) => _fetchCampaigns());
                    },
                    child: const Text("Lihat Semua"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildCampaignList(),
              const SizedBox(height: 24),
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
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignList() {
    if (_isLoadingCampaigns)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage));
    if (_campaigns.isEmpty)
      return const Center(child: Text("Belum ada penggalangan dana aktif."));

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
    double progress = (item.targetAmount > 0)
        ? (item.collectedAmount / item.targetAmount)
        : 0.0;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailPage(
              id: item.id,
              title: item.title,
              imageUrl: item.imageUrl,
              collected: item.collectedAmount,
              target: item.targetAmount,
            ),
          ),
        ).then((_) {
          _fetchCampaigns();
        });
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                item.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(height: 150, color: Colors.grey),
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
                        _formatCurrency(item.collectedAmount),
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

  // --- WIDGET HELPER ---

  Widget _buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _menuItem(Remix.hand_heart_fill, "Donasi", Colors.pink, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DonationPage()),
          ).then((_) => _fetchCampaigns());
        }),
        _menuItem(
          Remix.megaphone_fill,
          "Lapor",
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPage()),
          ),
        ),
        _menuItem(
          Remix.map_fill,
          "Peta",
          Colors.green,
          () => setState(() => _selectedIndex = 1),
        ),
        _menuItem(
          Remix.book_read_fill,
          "Edukasi",
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EducationPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $_userName!",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Row(
              children: [
                const Icon(
                  Remix.map_pin_2_fill,
                  color: Colors.blueAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                // Nama Lokasi Dinamis
                Text(
                  _location.length > 20
                      ? "${_location.substring(0, 18)}..."
                      : _location, // Truncate jika kepanjangan
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationPage()),
          ),
          icon: const Icon(Remix.notification_3_line, size: 28),
        ),
      ],
    );
  }

  // KARTU STATUS DINAMIS (CUACA REALTIME)
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_statusColor, _statusColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(_weatherIcon, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Status Cuaca Lokal:",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  _disasterStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$_weatherDesc • $_temp",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PanicButtonPage()),
      ),
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
                    "Tekan jika butuh pertolongan medis.",
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

  Widget _buildLiveFeedItem(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransparencyDetailPage(
              title: title,
              subtitle: subtitle,
              time: time,
            ),
          ),
        ),
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
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
    );
  }
}
