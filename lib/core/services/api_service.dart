import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT MODELS (SESUAIKAN JIKA NAMA FOLDER BEDA) ---
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';
// Perhatikan: reports_model.dart (pakai s)
import 'package:relawan_kita/features/emergency/data/models/reports_model.dart';
import 'package:relawan_kita/features/profile/data/models/certificate_model.dart';

class ApiService {
  // GANTI IP SESUAI KEBUTUHAN:
  // Emulator: "http://10.0.2.2:8000/api"
  // HP Fisik: "http://192.168.1.XX:8000/api" (Cek ipconfig)
  final String baseUrl = "http://10.0.2.2:8000/api";

  // ===========================================================================
  // 1. AUTHENTICATION (Login, Register, Logout)
  // ===========================================================================

  // --- LOGIN ---
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
        
        // Simpan NIK & Phone
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

  // --- REGISTER ---
  Future<bool> register(String name, String email, String password, String nik, String phone) async {
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

        // Auto Login setelah Register
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);
        await prefs.setInt('user_id', user['id']);
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

  // --- LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

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
        print("Gagal logout server (abaikan jika offline): $e");
      }
    }
    await prefs.clear();
  }

  // Cek Status Login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // ===========================================================================
  // 2. USER PROFILE
  // ===========================================================================

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'User',
      'email': prefs.getString('user_email') ?? '-',
      'nik': prefs.getString('user_nik') ?? '-',
      'phone': prefs.getString('user_phone') ?? '-',
    };
  }

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
        await prefs.setString('user_name', name);
        await prefs.setString('user_phone', phone);
        await prefs.setString('user_nik', nik);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error Update Profile: $e");
      return false;
    }
  }

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
          'new_password_confirmation': newPass,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update Password: $e");
      return false;
    }
  }

  // ===========================================================================
  // 3. CAMPAIGNS (DONASI)
  // ===========================================================================

  Future<List<CampaignModel>> getCampaigns() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/campaigns'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => CampaignModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error Get Campaigns: $e");
      return [];
    }
  }

  // ===========================================================================
  // 4. REPORTS (LAPORAN BENCANA)
  // ===========================================================================

  // Kirim Laporan
  Future<bool> submitReport({
    required String category,
    required String urgency,
    required String address,
    required String description,
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/reports'));
      
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['category'] = category;
      request.fields['urgency'] = urgency;
      request.fields['location_address'] = address;
      request.fields['description'] = description;

      var pic = await http.MultipartFile.fromPath('photo', imageFile.path);
      request.files.add(pic);

      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print("Gagal Upload Laporan: $respStr");
        return false;
      }
    } catch (e) {
      print("Error Submit Report: $e");
      return false;
    }
  }

  // Ambil Riwayat Laporan (DENGAN DEBUG)
  Future<List<ReportModel>> getMyReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/my-reports'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // --- DEBUG PRINT (Cek di Debug Console VSCode) ---
      print("HISTORY API - Status: ${response.statusCode}");
      print("HISTORY API - Body: ${response.body}");
      // -------------------------------------------------

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error Get My Reports: $e");
      return [];
    }
  }

  // ===========================================================================
  // 5. CERTIFICATES
  // ===========================================================================

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
        return [];
      }
    } catch (e) {
      print("Error Get Certificates: $e");
      return [];
    }
  }
}