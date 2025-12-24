import 'package:flutter/material.dart';


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

  // Fungsi Submit Laporan
  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (!_isPhotoUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lampirkan foto bukti kejadian.")),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Simulasi delay kirim ke server (2 detik)
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Tampilkan Dialog Sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Column(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text("Laporan Diterima"),
            ],
          ),
          content: const Text(
            "Terima kasih atas laporan Anda. \nID Tiket: #RP-2024-889\n\nTim relawan dan dinas terkait akan segera memverifikasi laporan ini.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Tutup Dialog
                Navigator.pop(context); // Kembali ke Home
              },
              child: const Text("Kembali ke Beranda"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lapor Kejadian")),
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
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Laporan palsu dapat dikenakan sanksi sesuai UU yang berlaku.",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Kategori Bencana
                    const Text(
                      "Jenis Kejadian",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Pilih kategori...",
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
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      validator: (val) => val == null ? "Wajib dipilih" : null,
                    ),
                    const SizedBox(height: 24),

                    // 2. Tingkat Urgensi (Custom Widget)
                    const Text(
                      "Tingkat Urgensi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                    const Text(
                      "Lokasi Kejadian",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      readOnly: true, // User tidak bisa edit manual (harus GPS)
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                        suffixIcon: TextButton(
                          onPressed: () {},
                          child: const Text("Refresh"),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Upload Foto Bukti
                    const Text(
                      "Foto Bukti (Wajib)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // Simulasi Ambil Foto
                        setState(() => _isPhotoUploaded = !_isPhotoUploaded);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isPhotoUploaded
                                  ? "Foto berhasil diunggah"
                                  : "Foto dihapus",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isPhotoUploaded
                              ? Colors.white
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isPhotoUploaded
                                ? Colors.green
                                : Colors.grey,
                            style: _isPhotoUploaded
                                ? BorderStyle.solid
                                : BorderStyle.none,
                          ),
                          image: _isPhotoUploaded
                              ? const DecorationImage(
                                  image: AssetImage('assets/images/banjir.jpg'),
                                  fit: BoxFit.cover,
                                ) // Pastikan aset ada, atau hapus baris ini jika belum ada
                              : null,
                        ),
                        child: _isPhotoUploaded
                            ? Container(
                                color: Colors.black38,
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Ketuk untuk ambil foto",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (!_isPhotoUploaded)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "* Foto wajib disertakan untuk validasi.",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // 5. Deskripsi Tambahan
                    const Text(
                      "Detail Kejadian",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            "Ceritakan kronologi atau kondisi detail di lokasi...",
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
                          backgroundColor: Colors.blueAccent,
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
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
