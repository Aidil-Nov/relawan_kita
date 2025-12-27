import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class CertificatePage extends StatelessWidget {
  const CertificatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> certificates = [
      {"title": "Basic Life Support", "issuer": "PMI", "id": "CERT-001"},
      {"title": "Water Rescue", "issuer": "BASARNAS", "id": "CERT-002"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Sertifikasi")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.amberAccent,
                    child: Icon(Remix.medal_fill, color: Colors.white),
                  ),
                  title: Text(cert['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${cert['issuer']} • ${cert['id']}"),
                  trailing: IconButton(
                    icon: const Icon(Remix.download_line, color: Colors.blue),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}