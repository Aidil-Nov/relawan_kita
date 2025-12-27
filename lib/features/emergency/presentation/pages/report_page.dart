import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; // <--- IMPORT REMIX ICON

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(
    text: "Jl. Merdeka No. 45, Pontianak (GPS Akurat)",
  );

  // State Variables
  String? _selectedCategory;
  int _selectedUrgency = 1; // 0: Rendah, 1: Sedang, 2: Tinggi
  bool _isPhotoUploaded = false; // Simulasi status upload
  bool _isLoading = false;

  // Data Mockup Kategori
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

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      // Validasi Tambahan: Pastikan Kategori Dipilih
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap pilih jenis kategori bencana.")),
        );
        return;
      }

      // Validasi Foto (Simulasi)
      if (!_isPhotoUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lampirkan foto bukti kejadian.")),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Simulasi Data JSON
      Map<String, dynamic> reportData = {
        "user_id": "DUMMY_USER_ID_123",
        "category": _selectedCategory,
        "urgency_level": _selectedUrgency,
        "location_address": _locationController.text,
        "description": _descController.text,
        "photo_url": "path/to/image.jpg",
        "status": "Menunggu Verifikasi",
        "timestamp": DateTime.now().toIso8601String(),
      };

      print("DATA LAPORAN SIAP KIRIM: $reportData");

      // Simulasi delay kirim ke server
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Tampilkan Dialog Sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              const Icon(
                Remix.checkbox_circle_fill,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 10),
              Text(
                "Laporan Diterima",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Terima kasih atas laporan Anda. \nID Tiket: #RP-2024-889\n\nTim relawan dan dinas terkait akan segera memverifikasi laporan ini.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text(
                "Kembali ke Beranda",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Lapor Kejadian",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Remix.information_line,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Laporan palsu dapat dikenakan sanksi sesuai UU yang berlaku.",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Kategori Bencana
                    Text(
                      "Jenis Kejadian",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Pilih kategori...",
                        prefixIcon: const Icon(
                          Remix.file_list_3_line,
                        ), // Icon Kategori
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      validator: (val) => val == null ? "Wajib dipilih" : null,
                    ),
                    const SizedBox(height: 24),

                    // 2. Tingkat Urgensi
                    Text(
                      "Tingkat Urgensi",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildUrgencyOption(0, "Rendah", Colors.green),
                        const SizedBox(width: 10),
                        _buildUrgencyOption(1, "Sedang", Colors.orange),
                        const SizedBox(width: 10),
                        _buildUrgencyOption(2, "Tinggi", Colors.red),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. Lokasi (Read Only)
                    Text(
                      "Lokasi Kejadian",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      readOnly: true, // User tidak bisa edit manual
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Remix.map_pin_2_fill,
                          color: Colors.red,
                        ),
                        suffixIcon: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Refresh",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Upload Foto Bukti
                    Text(
                      "Foto Bukti (Wajib)",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isPhotoUploaded = !_isPhotoUploaded);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isPhotoUploaded
                                  ? "Foto berhasil diunggah"
                                  : "Foto dihapus",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isPhotoUploaded
                              ? Colors.white
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isPhotoUploaded
                                ? Colors.green
                                : Colors.grey.shade300,
                            style: _isPhotoUploaded
                                ? BorderStyle.solid
                                : BorderStyle.solid,
                            width: 1.5,
                          ),
                          image: _isPhotoUploaded
                              ? const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/banjir.jpg',
                                  ), // Pastikan aset ada
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _isPhotoUploaded
                            ? Container(
                                color: Colors.black38,
                                child: const Center(
                                  child: Icon(
                                    Remix.checkbox_circle_fill,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Remix.camera_fill,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Ketuk untuk ambil foto",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (!_isPhotoUploaded)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "* Foto wajib disertakan untuk validasi.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // 5. Deskripsi Tambahan
                    Text(
                      "Detail Kejadian",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText:
                            "Ceritakan kronologi atau kondisi detail di lokasi...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return "Deskripsi tidak boleh kosong";
                        if (val.length < 10) return "Deskripsi terlalu singkat";
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "KIRIM LAPORAN",
                          style: TextStyle(
                            fontSize: 16,
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

  // WIDGET HELPER: Pilihan Urgensi
  Widget _buildUrgencyOption(int value, String label, Color color) {
    bool isSelected = _selectedUrgency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUrgency = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Remix.alarm_warning_fill, // Icon Urgensi
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Poppins', // Paksa font Poppins
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
