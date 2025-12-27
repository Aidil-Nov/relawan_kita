import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;

  // --- LOGIKA UBAH PASSWORD ---
  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
          left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ubah Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _passwordInput("Password Lama"),
            const SizedBox(height: 10),
            _passwordInput("Password Baru"),
            const SizedBox(height: 10),
            _passwordInput("Konfirmasi Password Baru"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password berhasil diubah!"), backgroundColor: Colors.green),
                  );
                },
                child: const Text("SIMPAN PASSWORD BARU", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _passwordInput(String label) {
    return TextField(
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
        decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
        child: const Icon(Remix.heart_pulse_fill, color: Colors.blue),
      ),
      children: [
        const SizedBox(height: 10),
        const Text("Aplikasi manajemen relawan bencana berbasis mobile untuk memudahkan koordinasi dan distribusi bantuan secara transparan."),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pengaturan"),
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line),
          onPressed: () => Navigator.pop(context),
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
            onTap: _showChangePasswordSheet,
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