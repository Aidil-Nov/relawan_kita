import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// --- IMPORTS LOGIC ---
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart';

// --- IMPORTS HALAMAN ANDA ---
import 'package:relawan_kita/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/certificate_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/settings_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/help_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 1. STATE VARIABLES (UPDATE: TAMBAH NIK & PHONE)
  String _name = "Loading...";
  String _email = "Loading...";
  String _phone = "";
  String _nik = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 2. LOGIC AMBIL DATA (UPDATE)
  void _loadUserData() async {
    final userData = await ApiService().getUserData();
    if (mounted) {
      setState(() {
        _name = userData['name'];
        _email = userData['email'];
        _phone = userData['phone']; // Ambil HP
        _nik = userData['nik']; // Ambil NIK
      });
    }
  }

  // 3. LOGIC LOGOUT (FIXED)
  void _handleLogout() {
    showDialog(
      context: context, // 'context' ini milik ProfilePage (Parent)
      builder: (dialogContext) {
        // <--- GANTI NAMA JADI dialogContext
        return AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext), // Tutup pakai dialogContext
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                // 1. Tutup Dialog dulu menggunakan dialogContext
                Navigator.pop(dialogContext);

                // 2. Proses Logout (Hapus Token & Request Server)
                await ApiService().logout();

                // 3. Cek apakah ProfilePage masih aktif
                if (!mounted) return;

                // 4. Navigasi ke Login menggunakan 'context' milik ProfilePage
                // (JANGAN pakai dialogContext di sini karena dialognya sudah mati)
                Navigator.pushAndRemoveUntil(
                  context, // <--- INI KUNCINYA (Pakai context Parent)
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Saya"),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Remix.logout_box_r_line, color: Colors.red),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER PROFIL ---
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  Remix.user_smile_line,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // NAMA
            Text(
              _name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // EMAIL
            Text(_email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 16),

            // --- INFO TAMBAHAN (UPDATE: TAMPILKAN NIK & HP) ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _infoRow(Remix.phone_line, _phone.isEmpty ? "-" : _phone),
                  const Divider(),
                  _infoRow(
                    Remix.shield_user_line,
                    "NIK: ${_nik.isEmpty ? "-" : _nik}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- MENU OPTIONS ---

            // 1. Edit Profil
            _buildProfileMenu(
              context,
              icon: Remix.user_settings_line,
              text: "Edit Profil",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                ).then((_) {
                  // Reload data saat kembali dari Edit Profil
                  _loadUserData();
                });
              },
            ),

            // 2. Sertifikat
            _buildProfileMenu(
              context,
              icon: Remix.medal_line,
              text: "Sertifikat Kompetensi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CertificatePage(),
                  ),
                );
              },
            ),

            // 3. Pengaturan
            _buildProfileMenu(
              context,
              icon: Remix.settings_3_line,
              text: "Pengaturan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),

            // 4. Pusat Bantuan
            _buildProfileMenu(
              context,
              icon: Remix.question_line,
              text: "Pusat Bantuan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget kecil untuk baris info NIK & HP
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Remix.arrow_right_s_line, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
