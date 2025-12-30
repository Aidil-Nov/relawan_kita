import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini untuk filter input angka
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/home/presentation/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller Text
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nikController = TextEditingController(); // BARU: Controller NIK
  final _phoneController = TextEditingController(); // BARU: Controller HP
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;

  void _handleRegister() async {
    // 1. Validasi Input Kosong (Cek semua field)
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _nikController.text.isEmpty || // Cek NIK
        _phoneController.text.isEmpty || // Cek HP
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi!")));
      return;
    }

    // Validasi NIK harus 16 digit
    if (_nikController.text.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("NIK harus 16 digit angka.")),
      );
      return;
    }

    // 2. Validasi Password Match
    if (_passwordController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Panggil API Register (Kirim 5 Data)
    bool success = await ApiService().register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _nikController.text, // Kirim NIK
      _phoneController.text, // Kirim HP
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      // Jika sukses, langsung masuk ke Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akun berhasil dibuat! Selamat datang."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal Mendaftar. Email atau NIK mungkin sudah terdaftar.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.blue),
            const SizedBox(height: 20),

            // Input Nama
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- INPUT BARU: NIK ---
            TextField(
              controller: _nikController,
              keyboardType: TextInputType.number, // Keyboard Angka
              maxLength: 16, // Batasi 16 karakter visual
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ], // Hanya boleh angka
              decoration: InputDecoration(
                labelText: "NIK (KTP)",
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: "", // Sembunyikan counter angka
              ),
            ),
            const SizedBox(height: 16),

            // --- INPUT BARU: NO HP ---
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Nomor WhatsApp / HP",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password (Min 8 karakter)",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Konfirmasi Password
            TextField(
              controller: _confirmPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Ulangi Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Daftar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
