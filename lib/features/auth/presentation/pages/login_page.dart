import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/home');
    }
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Remix.hand_heart_fill, size: 60, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text("Selamat Datang", style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text("Masuk untuk melanjutkan aktivitas relawan.", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 40),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Remix.mail_line),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || !val.contains("@")) ? "Email tidak valid" : null,
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text("Lupa Password?"),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("MASUK", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: TextSpan(
                        text: "Belum punya akun? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: "Daftar Sekarang",
                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
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