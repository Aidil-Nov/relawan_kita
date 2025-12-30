import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wajib ada
import 'package:relawan_kita/core/services/api_service.dart'; // Wajib ada

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nikController; 

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _nikController = TextEditingController();
    
    // Panggil fungsi untuk mengisi data saat ini
    _loadCurrentData();
  }

  // --- LOGIC 1: AMBIL DATA LAMA DARI HP ---
  void _loadCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? "";
      _emailController.text = prefs.getString('user_email') ?? "";
      _phoneController.text = prefs.getString('user_phone') ?? ""; 
      _nikController.text = prefs.getString('user_nik') ?? ""; 
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // --- LOGIC 2: SIMPAN KE SERVER & HP ---
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 1. Panggil API Update Profile ke Server Laravel
      bool success = await ApiService().updateProfile(
        _nameController.text,
        _phoneController.text,
        _nikController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;
      
      if (success) {
        // 2. Jika sukses, Update data di SharedPreferences (HP)
        // Ini PENTING agar saat kembali ke halaman Profil, datanya langsung berubah
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text);
        await prefs.setString('user_phone', _phoneController.text);
        await prefs.setString('user_nik', _nikController.text);

        Navigator.pop(context); // Kembali ke menu profil
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui profil. Cek koneksi atau NIK duplikat."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Remix.check_line, color: Colors.green),
            onPressed: _isLoading ? null : _saveProfile,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FOTO PROFIL (UI Saja, Backend foto menyusul)
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        image: DecorationImage(
                          image: _imageFile != null 
                            ? FileImage(_imageFile!) as ImageProvider
                            : const NetworkImage("https://i.pravatar.cc/300"), 
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Remix.camera_fill, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Form NIK (Bisa diedit agar User bisa melengkapi data)
              TextFormField(
                controller: _nikController, 
                readOnly: false, 
                style: const TextStyle(color: Colors.black87), 
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "NIK (KTP)",
                  prefixIcon: const Icon(Remix.shield_user_line),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                // Validasi NIK 16 Digit (Opsional, bisa diaktifkan jika mau strict)
                // validator: (val) => (val != null && val.length != 16) ? "NIK harus 16 digit" : null,
              ),
              const SizedBox(height: 16),

              // Form Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  prefixIcon: const Icon(Remix.user_line),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // Form HP
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Nomor WhatsApp",
                  prefixIcon: const Icon(Remix.whatsapp_line),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val!.isEmpty ? "Nomor wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Form Email (Read Only)
              TextFormField(
                controller: _emailController,
                readOnly: true, 
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: "Email (Tidak dapat diubah)",
                  prefixIcon: const Icon(Remix.mail_line),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Tombol Simpan Bawah
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN PERUBAHAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}