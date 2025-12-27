import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;
  bool _darkMode = false;

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
          SwitchListTile(
            secondary: const Icon(Remix.notification_3_line),
            title: const Text("Notifikasi Darurat"),
            value: _notifEnabled,
            onChanged: (val) => setState(() => _notifEnabled = val),
            activeColor: Colors.blueAccent,
          ),
          SwitchListTile(
            secondary: const Icon(Remix.moon_line),
            title: const Text("Mode Gelap"),
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
            activeColor: Colors.blueAccent,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Remix.lock_password_line),
            title: const Text("Ubah Password"),
            trailing: const Icon(Remix.arrow_right_s_line),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Remix.information_line),
            title: const Text("Tentang Aplikasi"),
            subtitle: const Text("Versi 1.0.0"),
          ),
        ],
      ),
    );
  }
}