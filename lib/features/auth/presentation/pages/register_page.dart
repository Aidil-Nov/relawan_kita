import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk input formatter (hanya angka)

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isVolunteer = false; // Checkbox untuk daftar jadi relawan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pendaftaran Akun"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Data Identitas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Sesuai standar data kependudukan (E-Gov).",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Nama Lengkap
                _buildTextField(label: "Nama Lengkap Sesuai KTP", icon: Icons.person),
                const SizedBox(height: 16),

                // NIK (Nomor Induk Kependudukan) - Validasi Penting
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(16), // Max 16 digit
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: "NIK (16 Digit)",
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    helperText: "Data dienkripsi dan diverifikasi dengan Dukcapil",
                  ),
                  validator: (value) {
                    if (value == null || value.length != 16) {
                      return "NIK harus 16 digit angka";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Upload KTP Mockup
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt, size: 40, color: Colors.blueAccent),
                      SizedBox(height: 8),
                      Text("Tap untuk Foto KTP", style: TextStyle(color: Colors.blueAccent)),
                      Text("(Wajib untuk verifikasi)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Akun & Keamanan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Email & Password
                _buildTextField(label: "Email Aktif", icon: Icons.email, inputType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                
                TextFormField(
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Opsi Relawan
                CheckboxListTile(
                  title: const Text("Daftar sebagai Relawan Aktif"),
                  subtitle: const Text("Saya bersedia dihubungi saat darurat."),
                  value: _isVolunteer,
                  onChanged: (val) => setState(() => _isVolunteer = val!),
                  activeColor: Colors.blueAccent,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 30),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Proses simpan data ke Database/Firebase
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Pendaftaran Berhasil! Silakan Login.")),
                        );
                        Navigator.pop(context); // Kembali ke Login
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("DAFTAR SEKARANG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget agar kodingan lebih rapi
  Widget _buildTextField({required String label, required IconData icon, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}