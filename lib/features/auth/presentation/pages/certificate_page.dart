import 'package:flutter/material.dart';

class CertificatePage extends StatelessWidget {
  const CertificatePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data Sertifikat
    final List<Map<String, String>> certificates = [
      {
        "title": "Basic Life Support (P3K)",
        "issuer": "Palang Merah Indonesia",
        "date": "2023",
        "id": "CERT-2023-001"
      },
      {
        "title": "Manajemen Dapur Umum",
        "issuer": "Dinas Sosial",
        "date": "2024",
        "id": "CERT-2024-882"
      },
      {
        "title": "Water Rescue Dasar",
        "issuer": "BASARNAS",
        "date": "2024",
        "id": "CERT-2024-991"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Sertifikasi Kompetensi")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Column(
              children: [
                // Header Sertifikat (Hiasan)
                Container(
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon Medali
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                      ),
                      const SizedBox(width: 16),
                      // Detail Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cert['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text("Penerbit: ${cert['issuer']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            Text("Tahun: ${cert['date']} • ID: ${cert['id']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Tombol Aksi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mengunduh sertifikat PDF...")));
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text("Unduh PDF"),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}