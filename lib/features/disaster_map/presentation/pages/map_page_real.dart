import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// Import package clustering
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:remixicon/remixicon.dart'; 

import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/emergency/data/models/reports_model.dart';

class MapPageReal extends StatefulWidget {
  const MapPageReal({super.key});

  @override
  State<MapPageReal> createState() => _MapPageRealState();
}

class _MapPageRealState extends State<MapPageReal> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  // Lokasi Default (Pontianak)
  final LatLng _centerLocation = const LatLng(-0.026330, 109.342504);
  LatLng? _userLocation;

  List<ReportModel> _reports = [];
  bool _isLoading = true;
  Timer? _autoRefreshTimer;

  String _activeFilter = "Semua";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchMapData(); 
    // Auto refresh setiap 30 detik agar sinyal SOS baru cepat muncul
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _fetchMapData(silent: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchMapData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final data = await ApiService().getPublicReports();
    if (mounted) {
      setState(() {
        _reports = data;
        _isLoading = false;
      });
    }
  }

  List<ReportModel> get _displayedReports {
    return _reports.where((report) {
      bool matchesCategory = _activeFilter == "Semua" || 
          report.category.toLowerCase().contains(_activeFilter.toLowerCase());
      bool matchesSearch = _searchQuery.isEmpty ||
          report.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GPS mati. Harap nyalakan GPS.")));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mencari lokasi Anda...")));
    Position position = await Geolocator.getCurrentPosition();
    setState(() => _userLocation = LatLng(position.latitude, position.longitude));
    _mapController.move(_userLocation!, 15.0);
  }

  Future<void> _openGoogleMaps(String latStr, String longStr) async {
    final Uri googleUrl = Uri.parse('http://googleusercontent.com/maps.google.com/maps?daddr=$latStr,$longStr');
    try { await launchUrl(googleUrl, mode: LaunchMode.externalApplication); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak dapat membuka peta."))); }
  }

  // [UPDATED] Menambahkan Style Khusus SOS
  Map<String, dynamic> _getMarkerStyle(String category) {
    String cat = category.toLowerCase();
    
    // 1. PRIORITAS UTAMA: SOS / DARURAT
    if (cat.contains('darurat') || cat.contains('sos')) {
      return {'color': Colors.redAccent, 'icon': Remix.alarm_warning_fill};
    }
    
    // 2. Kategori Lainnya
    if (cat.contains('banjir')) return {'color': Colors.blue, 'icon': Remix.rainy_fill};
    if (cat.contains('longsor')) return {'color': Colors.brown, 'icon': Remix.alert_fill};
    if (cat.contains('kebakaran')) return {'color': Colors.red, 'icon': Remix.fire_fill};
    if (cat.contains('jalan')) return {'color': Colors.grey[700]!, 'icon': Remix.road_map_fill};
    if (cat.contains('pohon')) return {'color': Colors.green, 'icon': Remix.tree_fill};
    if (cat.contains('sampah')) return {'color': Colors.orange, 'icon': Remix.delete_bin_2_fill};
    
    // Default
    return {'color': Colors.purple, 'icon': Remix.map_pin_fill};
  }

  // Helper untuk membuat List Marker
  List<Marker> _buildMarkers() {
    return _displayedReports.map((report) {
      final style = _getMarkerStyle(report.category);
      
      // Jika SOS, marker dibuat sedikit lebih besar
      bool isSOS = report.category.toLowerCase().contains('darurat') || report.category.toLowerCase().contains('sos');
      double size = isSOS ? 60.0 : 50.0;

      return Marker(
        point: LatLng(report.latitude, report.longitude),
        width: size,
        height: size,
        key: Key(report.id.toString()), 
        child: GestureDetector(
          onTap: () => _showLocationDetail(context, report, style),
          child: Container(
            decoration: BoxDecoration(
              color: isSOS ? Colors.red[50] : Colors.white, // Background merah muda jika SOS
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isSOS ? Colors.red.withOpacity(0.5) : Colors.black26, 
                  blurRadius: isSOS ? 10 : 4,
                  spreadRadius: isSOS ? 2 : 0, // Efek glow untuk SOS
                )
              ]
            ),
            child: Icon(style['icon'], color: style['color'], size: isSOS ? 35 : 30),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                // A. PETA DENGAN CLUSTERING
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
                    
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 120, 
                        size: const Size(45, 45), 
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(50),
                        markers: _buildMarkers(), 
                        
                        // Builder untuk Cluster (Kumpulan Marker)
                        builder: (context, markers) {
                          // Cek apakah ada SOS dalam cluster ini?
                          bool hasSOS = markers.any((m) {
                            // Cara sederhana cek key atau properti marker jika memungkinkan
                            // Tapi untuk visual sederhana, kita pakai biru default dulu
                            return false; 
                          });

                          return Container(
                            decoration: BoxDecoration(
                              color: hasSOS ? Colors.red : Colors.blueAccent, 
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)]
                            ),
                            child: Center(
                              child: Text(
                                markers.length.toString(), 
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Marker User (Lokasi Saya)
                    if (_userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _userLocation!,
                            width: 60, height: 60,
                            child: Container(
                              padding: const EdgeInsets.all(4), 
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle), 
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)]), 
                                child: const Icon(Remix.user_location_fill, color: Colors.white, size: 24)
                              )
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // B. SEARCH BAR & FILTER CATEGORY
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: "Cari lokasi atau bencana...",
                              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              prefixIcon: const Icon(Remix.search_line, color: Colors.grey),
                              suffixIcon: _searchQuery.isNotEmpty 
                                ? IconButton(icon: const Icon(Remix.close_circle_fill, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ""); }) 
                                : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            _filterChip("Semua", Colors.blueAccent),
                            _filterChip("Darurat/SOS", Colors.red), // [BARU] Filter Cepat SOS
                            _filterChip("Banjir", Colors.blue), 
                            _filterChip("Longsor", Colors.brown), 
                            _filterChip("Kebakaran", Colors.red), 
                            _filterChip("Pohon", Colors.green), 
                            _filterChip("Jalan", Colors.grey), 
                            _filterChip("Sampah", Colors.orange)
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),

                // C. TOMBOL AKSI
                Positioned(
                  bottom: 20, right: 20,
                  child: Column(children: [FloatingActionButton(heroTag: "refresh_map", mini: true, backgroundColor: Colors.white, onPressed: () => _fetchMapData(), child: const Icon(Remix.refresh_line, color: Colors.black87)), const SizedBox(height: 12), FloatingActionButton(heroTag: "gps_map", backgroundColor: Colors.white, onPressed: _getUserLocation, child: const Icon(Remix.focus_3_line, color: Colors.blueAccent))]),
                ),
              ],
            ),
          ),
    );
  }

  Widget _filterChip(String label, Color color) {
    bool isSelected = _activeFilter == label;
    // Khusus SOS, jika selected warna merah menyala
    if (label.contains('SOS') && isSelected) color = Colors.redAccent;

    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? color : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)], border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  // BOTTOM SHEET DETAIL LAPORAN
  void _showLocationDetail(BuildContext context, ReportModel report, Map<String, dynamic> style) {
    bool isSOS = report.category.toLowerCase().contains('darurat') || report.category.toLowerCase().contains('sos');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(
                  color: isSOS ? Colors.redAccent : style['color'].withOpacity(0.1), // Merah jika SOS
                  shape: BoxShape.circle
                ), 
                child: Icon(style['icon'], color: isSOS ? Colors.white : style['color'], size: 24)
              ), 
              const SizedBox(width: 12), 
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(report.category.toUpperCase(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isSOS ? Colors.red : null)), 
                Text(report.createdAt.length > 10 ? report.createdAt.substring(0, 10) : report.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12))
              ])), 
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Remix.close_line))
            ]), 
            const Divider(height: 24), 
            
            if (report.photoUrl.isNotEmpty && report.photoUrl != "null" && !report.photoUrl.contains('placeholder')) ...[
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(report.photoUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 100, color: Colors.grey[100], child: const Center(child: Text("Gagal memuat foto", style: TextStyle(color: Colors.grey)))))), 
              const SizedBox(height: 16)
            ], 
            
            Text("Kronologi:", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)), 
            const SizedBox(height: 4), 
            Text(report.description, style: Theme.of(context).textTheme.bodyMedium), 
            const SizedBox(height: 16), 
            
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Remix.map_pin_2_fill, size: 18, color: Colors.red), 
              const SizedBox(width: 8), 
              Expanded(child: Text(report.locationAddress, style: const TextStyle(fontSize: 13, color: Colors.black87)))
            ]), 
            
            const SizedBox(height: 24), 
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { _openGoogleMaps(report.latitude.toString(), report.longitude.toString()); }, icon: const Icon(Remix.direction_fill, color: Colors.white), label: const Text("Navigasi ke Lokasi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: isSOS ? Colors.red : Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))]),
        );
      },
    );
  }
}