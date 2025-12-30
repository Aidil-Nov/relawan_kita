import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/core/services/api_service.dart'; // Import API Service

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;

  // --- CONTROLLER TEXT (Untuk mengambil input user) ---
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan memori saat halaman ditutup
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // --- LOGIKA UBAH PASSWORD ---
  void _showChangePasswordSheet() {
    // Bersihkan form setiap kali sheet dibuka
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Gunakan StatefulBuilder agar bisa update tampilan (Loading) di dalam Sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            bool isLoading = false; // State lokal untuk loading tombol

            // Fungsi Simpan Internal
            void handleSave() async {
              // 1. Validasi Input Kosong
              if (_currentPassController.text.isEmpty ||
                  _newPassController.text.isEmpty ||
                  _confirmPassController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Semua kolom harus diisi")),
                );
                return;
              }

              // 2. Validasi Match
              if (_newPassController.text != _confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Konfirmasi password tidak cocok"),
                  ),
                );
                return;
              }

              // 3. Validasi Panjang
              if (_newPassController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password baru minimal 8 karakter"),
                  ),
                );
                return;
              }

              // Mulai Loading
              setSheetState(() => isLoading = true);

              // 4. Panggil API
              bool success = await ApiService().updatePassword(
                _currentPassController.text,
                _newPassController.text,
              );

              // Stop Loading
              setSheetState(() => isLoading = false);

              if (success) {
                if (!mounted) return;
                Navigator.pop(context); // Tutup Sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password berhasil diubah!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Gagal. Password lama mungkin salah."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ubah Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Input Password Lama
                  _passwordInput("Password Lama", _currentPassController),
                  const SizedBox(height: 10),

                  // Input Password Baru
                  _passwordInput("Password Baru", _newPassController),
                  const SizedBox(height: 10),

                  // Konfirmasi
                  _passwordInput(
                    "Konfirmasi Password Baru",
                    _confirmPassController,
                  ),
                  const SizedBox(height: 20),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Sesuaikan warna tema
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "SIMPAN PASSWORD BARU",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper Widget Input (Diupdate menerima Controller)
  Widget _passwordInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller, // Sambungkan Controller
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Remix.lock_password_line),
      ),
    );
  }

  // --- LOGIKA TENTANG APLIKASI ---
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "RelawanKita",
      applicationVersion: "1.0.0",
      applicationLegalese: "© 2024 RelawanKita Team",
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          shape: BoxShape.circle,
        ),
        child: const Icon(Remix.heart_pulse_fill, color: Colors.blue),
      ),
      children: [
        const SizedBox(height: 10),
        const Text(
          "Aplikasi manajemen relawan bencana berbasis mobile untuk memudahkan koordinasi dan distribusi bantuan secara transparan.",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          // Opsi Notifikasi
          SwitchListTile(
            secondary: const Icon(Remix.notification_3_line),
            title: const Text("Notifikasi Darurat"),
            value: _notifEnabled,
            onChanged: (val) => setState(() => _notifEnabled = val),
            activeColor: Colors.blueAccent,
          ),

          const Divider(),

          // Opsi Ubah Password
          ListTile(
            leading: const Icon(Remix.lock_password_line),
            title: const Text("Ubah Password"),
            trailing: const Icon(Remix.arrow_right_s_line),
            onTap: _showChangePasswordSheet, // Memanggil fungsi bottom sheet
          ),

          // Opsi Tentang Aplikasi
          ListTile(
            leading: const Icon(Remix.information_line),
            title: const Text("Tentang Aplikasi"),
            subtitle: const Text("Versi 1.0.0"),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }
}
