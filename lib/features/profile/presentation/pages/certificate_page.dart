import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/profile/data/models/certificate_model.dart';
import 'package:url_launcher/url_launcher.dart'; // Tambahkan package url_launcher di pubspec.yaml jika ingin fitur download jalan

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  List<CertificateModel> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  void _fetchCertificates() async {
    final data = await ApiService().getCertificates();
    if (mounted) {
      setState(() {
        _certificates = data;
        _isLoading = false;
      });
    }
  }

  // Fungsi dummy untuk download (Nanti bisa dikembangkan)
  void _downloadCertificate(String? url) async {
    if (url != null && url.isNotEmpty) {
       // Logic buka link browser
       final Uri uri = Uri.parse(url);
       if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
         if(!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
       }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File sertifikat belum tersedia untuk diunduh.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sertifikasi"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _certificates.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _certificates.length,
                  itemBuilder: (context, index) {
                    final cert = _certificates[index];
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
                            title: Text(cert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${cert.issuer} • ${cert.certificateCode}"),
                            trailing: IconButton(
                              icon: const Icon(Remix.download_line, color: Colors.blue),
                              onPressed: () => _downloadCertificate(cert.fileUrl),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Remix.award_line, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada sertifikat",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}