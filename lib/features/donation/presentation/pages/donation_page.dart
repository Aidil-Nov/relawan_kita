import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';
import 'package:relawan_kita/features/donation/presentation/pages/donation_detail_page.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  List<CampaignModel> _campaigns = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  void _fetchCampaigns() async {
    try {
      final data = await ApiService().getCampaigns();
      if (mounted) {
        setState(() {
          _campaigns = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat data. Cek koneksi internet.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Bantu Sesama", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Remix.search_line, color: Colors.black),
            onPressed: () {
              // Fitur pencarian bisa ditambahkan nanti
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur cari segera hadir!")));
            },
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Remix.wifi_off_line, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _fetchCampaigns, child: const Text("Coba Lagi"))
          ],
        ),
      );
    }

    if (_campaigns.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Remix.hand_heart_line, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("Belum ada program donasi aktif.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // LIST SEMUA CAMPAIGN
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _campaigns.length,
      itemBuilder: (context, index) {
        return _buildCampaignCard(_campaigns[index]);
      },
    );
  }

  Widget _buildCampaignCard(CampaignModel item) {
    double progress = item.collectedAmount / item.targetAmount;
    if (progress > 1.0) progress = 1.0;

    return GestureDetector(
      onTap: () {
        // NAVIGASI KE DETAIL (KIRIM ID)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailPage(
              id: item.id,
              title: item.title,
              imageUrl: item.imageUrl,
              collected: item.collectedAmount.toDouble(),
              target: item.targetAmount.toDouble(),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                item.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 180, color: Colors.grey[300], child: const Center(child: Icon(Icons.image, color: Colors.grey))),
              ),
            ),
            // KONTEN TEKS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Remix.user_heart_line, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("Oleh ${item.organizer}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[200],
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  
                  // Info Nominal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Terkumpul", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          Text(
                            "Rp ${_formatCurrency(item.collectedAmount.toInt())}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Target", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          Text(
                            "Rp ${_formatCurrency(item.targetAmount.toInt())}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int number) {
    // Helper sederhana untuk format angka (bisa pakai package intl kalau mau lebih rapi)
    if (number >= 1000000000) {
      return "${(number / 1000000000).toStringAsFixed(1)}M";
    } else if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}jt";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(0)}rb";
    }
    return number.toString();
  }
}