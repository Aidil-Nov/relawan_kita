import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:remixicon/remixicon.dart'; // <--- IMPORT REMIX ICON

class MapPageReal extends StatefulWidget {
  const MapPageReal({super.key});

  @override
  State<MapPageReal> createState() => _MapPageRealState();
}

class _MapPageRealState extends State<MapPageReal> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final LatLng _centerLocation = const LatLng(-0.026330, 109.342504);
  LatLng? _userLocation;

  String _activeFilter = "Semua";
  String _searchQuery = "";

  // MASTER DATA
  final List<Map<String, dynamic>> _allPoints = [
    {
      "id": "1",
      "lat": -0.022,
      "long": 109.330,
      "type": "Banjir",
      "desc": "Air setinggi 50cm di jalan utama.",
      "color": Colors.red,
      "icon": Remix.rainy_fill, // Icon Banjir
    },
    {
      "id": "2",
      "lat": -0.030,
      "long": 109.350,
      "type": "Posko",
      "desc": "Dapur Umum & Pos Medis 24 Jam.",
      "color": Colors.green,
      "icon": Remix.tent_fill, // Icon Tenda/Posko
    },
    {
      "id": "3",
      "lat": -0.015,
      "long": 109.345,
      "type": "Longsor",
      "desc": "Tebing rawan longsor, harap hindari.",
      "color": Colors.orange,
      "icon": Remix.alert_fill, // Icon Bahaya
    },
    {
      "id": "4",
      "lat": -0.028,
      "long": 109.335,
      "type": "Posko",
      "desc": "Tempat Pengungsian Balai Desa.",
      "color": Colors.green,
      "icon": Remix.tent_fill,
    },
  ];

  List<Map<String, dynamic>> get _displayedMarkers {
    return _allPoints.where((point) {
      bool matchesCategory = _activeFilter == "Semua" || point['type'] == _activeFilter;
      bool matchesSearch =
          point['type'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          point['desc'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GPS mati. Harap nyalakan GPS.")));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mencari lokasi Anda...")));
    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_userLocation!, 15.0);
  }

  Future<void> _openGoogleMaps(double lat, double long) async {
    final Uri googleUrl = Uri.parse('http://googleusercontent.com/maps.google.com/?daddr=$lat,$long');
    try {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak dapat membuka peta.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onTap: (_, __) => FocusScope.of(context).unfocus(),
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
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showLocationDetail(context, point),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                            ),
                            child: Icon(
                              point['icon'], // Icon Dinamis dari Data
                              color: point['color'],
                              size: 30,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    
                    // Marker User
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 60,
                        height: 60,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                            ),
                            child: const Icon(Remix.user_location_fill, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // B. SEARCH BAR & FILTER
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // SEARCH BAR
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: "Cari posko, dapur umum...",
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          prefixIcon: const Icon(Remix.search_line, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Remix.close_circle_fill, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = "");
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                child: const Icon(Remix.focus_3_line, color: Colors.blueAccent),
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
            fontFamily: 'Poppins', // Paksa font Poppins
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: data['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(data['icon'], color: data['color'], size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    data['type'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Remix.close_line),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                data['desc'], 
                style: Theme.of(context).textTheme.bodyLarge
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(data['lat'], data['long']),
                  icon: const Icon(Remix.direction_fill, color: Colors.white), // Icon Navigasi
                  label: const Text("Navigasi (Google Maps)", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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