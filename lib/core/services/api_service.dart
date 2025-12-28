import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';

class ApiService {
  // Ganti IP ini sesuai perangkat Anda (10.0.2.2 khusus Emulator Android)
  final String baseUrl = "http://172.20.10.6:8000/api";

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

  // FUNGSI BARU: KIRIM LAPORAN
  Future<bool> submitReport({
    required String category,
    required String urgency,
    required String address,
    required String description,
    required File imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/reports'));

      // --- TAMBAHKAN BAGIAN INI ---
      // Memberitahu Laravel: "Tolong jangan kirim HTML, kirim JSON saja kalau error"
      request.headers.addAll({
        'Accept': 'application/json',
      });
      // ----------------------------

      request.fields['category'] = category;
      request.fields['urgency'] = urgency;
      request.fields['location_address'] = address;
      request.fields['description'] = description;

      var pic = await http.MultipartFile.fromPath('photo', imageFile.path);
      request.files.add(pic);

      var response = await request.send();

      // Baca respon server
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; 
      } else {
        // Log error biar terbaca di Debug Console
        print("Gagal Upload (Status ${response.statusCode}): $respStr");
        return false;
      }
    } catch (e) {
      print("Error API: $e");
      return false;
    }
  }
}
