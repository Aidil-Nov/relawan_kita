import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Notifikasi Darurat"),
            subtitle: const Text("Terima peringatan bencana real-time"),
            value: _notifEnabled,
            onChanged: (val) => setState(() => _notifEnabled = val),
            activeColor: Colors.blueAccent,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Mode Gelap"),
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          const Divider(),
          ListTile(
            title: const Text("Ubah Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Bahasa / Language"),
            subtitle: const Text("Bahasa Indonesia"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
           const Divider(),
           ListTile(
            title: const Text("Versi Aplikasi"),
            subtitle: const Text("1.0.0 (Beta)"),
          ),
        ],
      ),
    );
  }
}