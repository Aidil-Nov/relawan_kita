import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:relawan_kita/features/profile/data/models/certificate_model.dart'; // Import model baru

class ApiService {
  // Ganti IP ini sesuai perangkat Anda
  // Pastikan IP ini benar jika pakai HP fisik (bukan Emulator)
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<List<CampaignModel>> getCampaigns() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/campaigns'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => CampaignModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // --- FUNGSI KIRIM LAPORAN (PERBAIKAN: TAMBAH TOKEN) ---
  Future<bool> submitReport({
    required String category,
    required String urgency,
    required String address,
    required String description,
    required File imageFile,
  }) async {
    try {
      // 1. Ambil Token dulu
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reports'),
      );

      // 2. Kirim Header Token (PENTING!)
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization':
            'Bearer $token', // <--- Wajib ada biar gak 401 Unauthorized
      });

      request.fields['category'] = category;
      request.fields['urgency'] = urgency;
      request.fields['location_address'] = address;
      request.fields['description'] = description;

      var pic = await http.MultipartFile.fromPath('photo', imageFile.path);
      request.files.add(pic);

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Gagal Upload (Status ${response.statusCode}): $respStr");
        return false;
      }
    } catch (e) {
      print("Error API: $e");
      return false;
    }
  }

  // --- FUNGSI LOGIN ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['data']['token'];
        Map<String, dynamic> user = data['data']['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);
        await prefs.setInt('user_id', user['id']);

        // Simpan NIK & PHONE
        await prefs.setString('user_nik', user['nik'] ?? '-');
        await prefs.setString('user_phone', user['phone'] ?? '-');

        return true;
      } else {
        print("Login Gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Login: $e");
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // --- FUNGSI REGISTER ---
  Future<bool> register(
    String name,
    String email,
    String password,
    String nik,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'nik': nik,
          'phone': phone,
        },
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String token = data['data']['token'];
        Map<String, dynamic> user = data['data']['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);
        await prefs.setInt('user_id', user['id']);

        // Simpan NIK & PHONE
        await prefs.setString('user_nik', user['nik'] ?? '-');
        await prefs.setString('user_phone', user['phone'] ?? '-');

        return true;
      } else {
        print("Register Gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Register: $e");
      return false;
    }
  }

  // --- FUNGSI LOGOUT (PERBAIKAN: CALL SERVER) ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // 1. Beritahu server untuk hapus token
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        print("Gagal logout di server (abaikan jika offline): $e");
      }
    }

    // 2. Hapus data di HP
    await prefs.clear();
  }

  // --- AMBIL DATA USER ---
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'User',
      'email': prefs.getString('user_email') ?? '-',
      'nik': prefs.getString('user_nik') ?? '-',
      'phone': prefs.getString('user_phone') ?? '-',
    };
  }

  // --- UPDATE PROFIL ---
  Future<bool> updateProfile(String name, String phone, String nik) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/update-profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'name': name, 'phone': phone, 'nik': nik},
      );

      if (response.statusCode == 200) {
        // Update data di HP biar sinkron
        await prefs.setString('user_name', name);
        await prefs.setString('user_phone', phone);
        await prefs.setString('user_nik', nik);
        return true;
      } else {
        print("Gagal Update: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Update Profile: $e");
      return false;
    }
  }
  // ... fungsi lainnya ...

  // --- GANTI PASSWORD ---
  Future<bool> updatePassword(String currentPass, String newPass) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/update-password'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'current_password': currentPass,
          'new_password': newPass,
          'new_password_confirmation': newPass, // Konfirmasi otomatis sama
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal Ganti Password: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Update Password: $e");
      return false;
    }
  }

  Future<List<CertificateModel>> getCertificates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/certificates'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => CertificateModel.fromJson(json)).toList();
      } else {
        return []; // Return list kosong jika gagal
      }
    } catch (e) {
      print("Error Get Certificates: $e");
      return [];
    }
  }
}
