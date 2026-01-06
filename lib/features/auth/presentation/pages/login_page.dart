import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
// --- IMPORTS PENTING ---
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/home/presentation/pages/home_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // --- LOGIKA LOGIN ---
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool success = await ApiService().login(
        _emailController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Gagal! Cek email dan password Anda."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- FITUR LUPA PASSWORD (BOTTOM SHEET) ---
  void _showForgotPasswordSheet() {
    final emailResetController = TextEditingController();
    final newPassResetController = TextEditingController();
    
    // Isi otomatis jika user sudah ketik email di login form
    if (_emailController.text.isNotEmpty) {
      emailResetController.text = _emailController.text;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar keyboard tidak menutupi
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            bool isResetLoading = false;

            void handleReset() async {
              if (emailResetController.text.isEmpty || newPassResetController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi Email & Password Baru")));
                return;
              }
              if (newPassResetController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password minimal 8 karakter")));
                return;
              }

              setSheetState(() => isResetLoading = true);
              
              // Panggil API Reset Dev
              bool success = await ApiService().resetPasswordDev(
                emailResetController.text,
                newPassResetController.text
              );

              setSheetState(() => isResetLoading = false);

              if (success) {
                Navigator.pop(context); // Tutup Sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password berhasil direset! Silakan login."), backgroundColor: Colors.green)
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal! Email tidak ditemukan."), backgroundColor: Colors.red)
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reset Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Masukkan email akun Anda dan password baru yang diinginkan.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: emailResetController,
                    decoration: InputDecoration(
                      labelText: "Email Terdaftar",
                      prefixIcon: const Icon(Remix.mail_line),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassResetController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password Baru",
                      prefixIcon: const Icon(Remix.lock_line),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isResetLoading ? null : handleReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: isResetLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("RESET PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Remix.hand_heart_fill, size: 60, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 24),

                  // --- JUDUL ---
                  Text("Selamat Datang", style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text("Masuk untuk melanjutkan aktivitas relawan.", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 40),

                  // --- INPUT EMAIL ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Remix.mail_line),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || !val.contains("@")) ? "Email tidak valid" : null,
                  ),
                  const SizedBox(height: 16),

                  // --- INPUT PASSWORD ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Remix.lock_2_line),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Remix.eye_line : Remix.eye_off_line),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val!.isEmpty ? "Password wajib diisi" : null,
                  ),

                  // --- TOMBOL LUPA PASSWORD (AKTIF) ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordSheet, // Panggil Fungsi
                      child: const Text("Lupa Password?"),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL MASUK ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("MASUK", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // TOMBOL TAMU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Masuk sebagai Tamu", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                        child: Text("Daftar Sekarang", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  