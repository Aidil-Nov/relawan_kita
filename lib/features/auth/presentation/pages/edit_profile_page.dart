import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller dummy...
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        actions: [
          IconButton(
            icon: const Icon(Remix.check_line, color: Colors.green),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Remix.camera_fill, size: 16, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            TextFormField(
              initialValue: "617103...",
              readOnly: true,
              decoration: InputDecoration(
                labelText: "NIK (Permanen)",
                prefixIcon: const Icon(Remix.shield_user_line), // Icon Shield
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: "Budi Santoso",
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: const Icon(Remix.user_line),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            // ... Tambahkan field lain sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}