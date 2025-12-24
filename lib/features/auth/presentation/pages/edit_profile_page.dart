import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk menangani input teks
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nikController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data awal (Mock Data / Data Dummy saat ini)
    _nameController = TextEditingController(text: "Budi Santoso");
    _phoneController = TextEditingController(text: "081234567890");
    _emailController = TextEditingController(text: "budi.santoso@email.com");
    _nikController = TextEditingController(text: "6171032508900001"); // NIK
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  // Fungsi Simpan Data
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulasi request ke database (delay 2 detik)
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Kembalikan data baru ke halaman sebelumnya (untuk update tampilan)
      Navigator.pop(context, {
        'name': _nameController.text,
        'phone': _phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveProfile,
            icon: const Icon(Icons.check, color: Colors.blueAccent),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 1. FOTO PROFIL EDITABLE
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blueAccent, width: 2),
                              image: const DecorationImage(
                                image: NetworkImage("https://i.pravatar.cc/300"), // Avatar dummy
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 2. NIK (READ ONLY / TIDAK BISA DIEDIT)
                    // Dalam E-Gov, NIK adalah kunci utama dan tidak boleh diubah user sembarangan
                    TextFormField(
                      controller: _nikController,
                      readOnly: true, 
                      style: const TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: "NIK (Tidak dapat diubah)",
                        prefixIcon: const Icon(Icons.badge),
                        filled: true,
                        fillColor: Colors.grey[200], // Memberi visual bahwa ini disable
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. NAMA LENGKAP
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 20),

                    // 4. NOMOR HP
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Nomor WhatsApp",
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val!.isEmpty ? "Nomor HP wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),

                    // 5. EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => !val!.contains("@") ? "Email tidak valid" : null,
                    ),

                    const SizedBox(height: 40),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: const Text("SIMPAN PERUBAHAN"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}