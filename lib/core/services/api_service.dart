import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';

class ApiService {
  // Ganti IP ini sesuai perangkat Anda (10.0.2.2 khusus Emulator Android)
  final String baseUrl = "http://192.168.1.10:8000/api";

  Future<List<CampaignModel>> getCampaigns() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/campaigns'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];

        // Ubah list JSON menjadi List CampaignModel
        return data.map((json) => CampaignModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
}