import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk input formatter (hanya angka)

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Kunci Validasi Form
  final _formKey = GlobalKey<FormState>();

  // 2. Controllers (Penampung Data)
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State untuk Loading & Show Password
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Wajib dispose untuk mencegah kebocoran memori
    _nikController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA REGISTER (SIAP HUBUNG KE DATABASE) ---
  void _handleRegister() async {
    // 1. Cek Validasi Input
    if (_formKey.currentState!.validate()) {
      // 2. Tampilkan Loading (UI)
      setState(() => _isLoading = true);

      // 3. Tangkap Data ke Variable (Siap Kirim ke Database)
      Map<String, dynamic> userData = {
        "nik": _nikController.text.trim(),
        "nama": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "no_hp": _phoneController.text.trim(),
        "password": _passwordController.text, // Nanti di-hash di backend
        "role": "user", // Default role
        "created_at": DateTime.now().toIso8601String(),
      };

      // TODO: DI SINI NANTI KITA PASTE KODE FIREBASE/API
      print("MENGIRIM DATA KE DATABASE: $userData");

      // Simulasi delay jaringan (2 detik)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 4. Sukses -> Pindah ke Login atau Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran Berhasil! Silakan Login."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke halaman Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Buat Akun Baru",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Text(
                  "Bergabung menjadi bagian dari relawan tangguh.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // --- INPUT NIK (FIELD E-GOV) ---
                TextFormField(
                  controller: _nikController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ], // Hanya Angka
                  maxLength: 16, // Standar NIK KTP
                  decoration: InputDecoration(
                    labelText: "NIK (Nomor Induk Kependudukan)",
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "", // Hilangkan counter karakter di bawah
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "NIK wajib diisi";
                    if (value.length != 16) return "NIK harus 16 digit angka";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- INPUT NAMA LENGKAP ---
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap (Sesuai KTP)",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Nama tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),

                // --- INPUT EMAIL ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Alamat Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Email wajib diisi";
                    if (!value.contains('@')) return "Format email salah";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- INPUT NO HP ---
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Nomor WhatsApp",
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Nomor HP wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // --- INPUT PASSWORD ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Password wajib diisi";
                    if (value.length < 6) return "Password minimal 6 karakter";
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // --- TOMBOL DAFTAR ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "DAFTAR SEKARANG",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Login di sini",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
