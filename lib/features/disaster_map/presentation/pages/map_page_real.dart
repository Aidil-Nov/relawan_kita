import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MapPageReal extends StatefulWidget {
  const MapPageReal({super.key});

  @override
  State<MapPageReal> createState() => _MapPageRealState();
}

class _MapPageRealState extends State<MapPageReal> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController =
      TextEditingController(); // Controller Input

  final LatLng _centerLocation = const LatLng(-0.026330, 109.342504);
  LatLng? _userLocation;

  // State Filter
  String _activeFilter = "Semua";
  String _searchQuery = ""; // Menyimpan teks yang diketik user

  // MASTER DATA
  final List<Map<String, dynamic>> _allPoints = [
    {
      "id": "1",
      "lat": -0.022,
      "long": 109.330,
      "type": "Banjir",
      "desc": "Air setinggi 50cm di jalan utama.",
      "color": Colors.red,
    },
    {
      "id": "2",
      "lat": -0.030,
      "long": 109.350,
      "type": "Posko",
      "desc": "Dapur Umum & Pos Medis 24 Jam.",
      "color": Colors.green,
    },
    {
      "id": "3",
      "lat": -0.015,
      "long": 109.345,
      "type": "Longsor",
      "desc": "Tebing rawan longsor, harap hindari.",
      "color": Colors.orange,
    },
    {
      "id": "4",
      "lat": -0.028,
      "long": 109.335,
      "type": "Posko",
      "desc": "Tempat Pengungsian Balai Desa.",
      "color": Colors.green,
    },
  ];

  // LOGIKA FILTER GANDA (CHIP + SEARCH BAR)
  List<Map<String, dynamic>> get _displayedMarkers {
    return _allPoints.where((point) {
      // 1. Cek Kategori (Chip)
      bool matchesCategory =
          _activeFilter == "Semua" || point['type'] == _activeFilter;

      // 2. Cek Search Text (Nama Tipe ATAU Deskripsi)
      // Kita gunakan .toLowerCase() agar pencarian tidak peduli huruf besar/kecil
      bool matchesSearch =
          point['type'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          point['desc'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Marker muncul HANYA JIKA kedua syarat terpenuhi
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // --- LOGIKA LAINNYA TETAP SAMA ---

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("GPS mati. Harap nyalakan GPS.")),
        );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Mencari lokasi Anda...")));
    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_userLocation!, 15.0);
  }

  Future<void> _openGoogleMaps(double lat, double long) async {
    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$long?daddr=$lat,$long',
    ); // Tambah daddr agar lebih akurat
    try {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak dapat membuka peta.")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tambahkan Listener agar keyboard turun saat tap peta
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // A. PETA
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centerLocation,
                initialZoom: 13.0,
                onTap: (_, __) => FocusScope.of(
                  context,
                ).unfocus(), // Tutup keyboard saat klik peta
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.relawankita.app',
                ),
                MarkerLayer(
                  markers: [
                    ..._displayedMarkers.map((point) {
                      return Marker(
                        point: LatLng(point['lat'], point['long']),
                        width: 45,
                        height: 45,
                        child: GestureDetector(
                          onTap: () => _showLocationDetail(context, point),
                          child: Icon(
                            Icons.location_on,
                            color: point['color'],
                            size: 45,
                            shadows: const [
                              Shadow(color: Colors.black38, blurRadius: 5),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 60,
                        height: 60,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // B. SEARCH BAR & FILTER (YANG DIPERBAIKI)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // SEARCH BAR AKTIF
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          // Update State saat user mengetik
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Cari posko, dapur umum...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = "");
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // CHIP FILTER
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip("Semua", Colors.blue),
                          _filterChip("Banjir", Colors.red),
                          _filterChip("Posko", Colors.green),
                          _filterChip("Longsor", Colors.orange),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // C. TOMBOL MY LOCATION
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _getUserLocation,
                child: const Icon(Icons.my_location, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, Color color) {
    bool isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showLocationDetail(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: data['color'], size: 30),
                  const SizedBox(width: 10),
                  Text(
                    data['type'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(data['desc'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(data['lat'], data['long']),
                  icon: const Icon(Icons.turn_right),
                  label: const Text("Navigasi (Google Maps)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
