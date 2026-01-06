import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// --- IMPORTS LOGIC ---
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart';

// --- IMPORTS HALAMAN LAIN ---
import 'package:relawan_kita/features/profile/presentation/pages/edit_profile_page.dart'; 
import 'package:relawan_kita/features/profile/presentation/pages/certificate_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/settings_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/help_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // STATE VARIABLES
  String _name = "Loading...";
  String _email = "Loading...";
  String _phone = "";
  String _nik = "";
  String? _photoUrl; 
  bool _isGuest = true; // Default tamu

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // LOGIC CEK STATUS LOGIN
  void _checkStatus() async {
    bool login = await ApiService().isLoggedIn();
    if (mounted) {
      setState(() => _isGuest = !login); 
    }
    if (!_isGuest) {
        _loadUserData(); 
    }
  }

  void _loadUserData() async {
    final userData = await ApiService().getUserData();
    if (mounted) {
      setState(() {
        _name = userData['name'];
        _email = userData['email'];
        _phone = userData['phone']; 
        _nik = userData['nik']; 
        _photoUrl = userData['photo_url']; 
      });
    }
  }

  void _handleLogout() {
    showDialog(
      context: context, 
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ApiService().logout();

                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // [TAMPILAN KHUSUS TAMU]
    if (_isGuest) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Remix.lock_2_line, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  "Akses Terbatas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan login untuk melihat profil, sertifikat, dan pengaturan akun Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("LOGIN SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // [TAMPILAN USER LOGIN]
    ImageProvider? avatarImage;
    if (_photoUrl != null && _photoUrl!.isNotEmpty && _photoUrl != "null") {
      avatarImage = NetworkImage(_photoUrl!);
    }

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
            Center(
              child: Container(
                width: 100, 
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  image: avatarImage != null 
                      ? DecorationImage(
                          image: avatarImage,
                          fit: BoxFit.cover,
                          onError: (e, s) => debugPrint("Error load avatar: $e"),
                        ) 
                      : null,
                ),
                child: avatarImage == null 
                    ? const Icon(Remix.user_smile_line, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              _name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(_email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 16),

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

            _buildProfileMenu(
              context,
              icon: Remix.user_settings_line,
              text: "Edit Profil",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                ).then((res) {
                  if (res == true) _loadUserData(); else _loadUserData();
                });
              },
            ),

            _buildProfileMenu(
              context,
              icon: Remix.medal_line,
              text: "Sertifikat Kompetensi",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CertificatePage()));
              },
            ),

            _buildProfileMenu(
              context,
              icon: Remix.settings_3_line,
              text: "Pengaturan",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              },
            ),

            _buildProfileMenu(
              context,
              icon: Remix.question_line,
              text: "Pusat Bantuan",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Remix.arrow_right_s_line, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}