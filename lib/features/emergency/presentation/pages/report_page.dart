import 'dart:io'; // PENTING: Untuk akses File foto
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // PENTING: Plugin Kamera
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:geolocator/geolocator.dart'; // Untuk Koordinat
import 'package:geocoding/geocoding.dart'; // Untuk Alamat Jalan
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // State Variables
  String? _selectedCategory;
  int _selectedUrgency = 1;

  // UBAH DARI BOOLEAN KE FILE
  File? _imageFile; // Menyimpan file foto asli
  final ImagePicker _picker = ImagePicker(); // Inisialisasi Picker

  bool _isLoading = false;
  bool _isGettingLocation = false;

  final List<String> _categories = [
    'Banjir / Genangan',
    'Tanah Longsor',
    'Pohon Tumbang',
    'Kebakaran',
    'Jalan Rusak Parah',
    'Tumpukan Sampah Liar',
    'Lainnya',
  ];

  @override
  void dispose() {
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- FUNGSI BUKA KAMERA / GALERI ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Kompres foto biar tidak terlalu besar
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path); // Simpan path foto
        });
      }
    } catch (e) {
      debugPrint("Error ambil foto: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil foto")));
    }
  }

  // --- DIALOG PILIH SUMBER FOTO ---
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ambil Foto Dari",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceButton(
                  icon: Remix.camera_fill,
                  label: "Kamera",
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _sourceButton(
                  icon: Remix.image_fill,
                  label: "Galeri",
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[50],
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- FUNGSI GPS ASLI (REAL-TIME) ---
  void _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // 1. Cek apakah GPS di HP nyala?
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Layanan lokasi (GPS) mati. Mohon nyalakan.';
      }

      // 2. Cek Izin Aplikasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Buka pengaturan HP.';
      }

      // 3. Ambil Titik Koordinat (Latitude & Longitude)
      // Menggunakan High Accuracy agar pas di titik berdiri
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Ubah Koordinat jadi Alamat (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Susun alamat agar rapi
      String fullAddress = "Lokasi tidak dikenali";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format: Jl. Nama Jalan, Kecamatan, Kota
        fullAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}";
      }

      // 5. Update UI
      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
        // Tampilkan Alamat di Textfield
        _locationController.text = fullAddress;

        // Simpan Koordinat di variabel (Opsional: Jika nanti mau dikirim ke Database)
        // _latitude = position.latitude;
        // _longitude = position.longitude;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGettingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal GPS: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // GANTI FUNGSI _submitReport DENGAN INI:
  void _submitReport() async {
    // 1. CEK LOGIN
    bool isLogin = await ApiService().isLoggedIn();
    if (!isLogin) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Login Diperlukan"),
          content: const Text(
            "Anda harus login untuk mengirim laporan bencana.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginPage()),
                );
              },
              child: const Text("Login"),
            ),
          ],
        ),
      );
      return;
    }

    // 2. LOGIKA SUBMIT SEBELUMNYA
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih kategori bencana.")),
        );
        return;
      }
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wajib lampirkan foto bukti.")),
        );
        return;
      }
      setState(() => _isLoading = true);
      bool isSuccess = await ApiService().submitReport(
        category: _selectedCategory!,
        urgency: _selectedUrgency == 0
            ? 'Rendah'
            : (_selectedUrgency == 1 ? 'Sedang' : 'Tinggi'),
        address: _locationController.text,
        description: _descController.text,
        imageFile: _imageFile!,
      );
      setState(() => _isLoading = false);
      if (!mounted) return;
      if (isSuccess) {
        _showSuccessDialog("SENT-OK");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengirim laporan."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Remix.checkbox_circle_fill,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              "Laporan Terkirim!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "ID Tiket: #$ticketId",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lapor Kejadian"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KATEGORI
              _label("Jenis Kejadian"),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: "Pilih kategori...",
                  prefixIcon: const Icon(Remix.file_list_3_line),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 20),

              // 2. URGENSI
              _label("Tingkat Urgensi"),
              Row(
                children: [
                  _urgencyOption(0, "Rendah", Colors.green),
                  const SizedBox(width: 10),
                  _urgencyOption(1, "Sedang", Colors.orange),
                  const SizedBox(width: 10),
                  _urgencyOption(2, "Tinggi", Colors.red),
                ],
              ),
              const SizedBox(height: 20),

              // 3. LOKASI
              _label("Lokasi Kejadian"),
              TextFormField(
                controller: _locationController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Ambil lokasi via GPS",
                  prefixIcon: const Icon(
                    Remix.map_pin_2_line,
                    color: Colors.red,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    icon: _isGettingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Remix.gps_fill, color: Colors.blue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (val) => val!.isEmpty ? "Lokasi wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              // 4. FOTO BUKTI (REAL CAMERA)
              _label("Foto Bukti (Wajib)"),
              GestureDetector(
                onTap:
                    _showImageSourceDialog, // Buka Dialog Pilih Kamera/Galeri
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _imageFile != null
                          ? Colors.green
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(
                              _imageFile!,
                            ), // Tampilkan File Asli
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Remix.camera_lens_line,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Ketuk untuk ambil foto",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        )
                      : Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Remix.close_line,
                                size: 16,
                                color: Colors.red,
                              ),
                              onPressed: () => setState(
                                () => _imageFile = null,
                              ), // Hapus Foto
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. DESKRIPSI
              _label("Detail Kejadian"),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Ceritakan detail kejadian...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 30),

              // TOMBOL KIRIM
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "KIRIM LAPORAN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _urgencyOption(int value, String label, Color color) {
    bool isSelected = _selectedUrgency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUrgency = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Remix.alarm_warning_fill,
                color: isSelected ? color : Colors.grey[400],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
