import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT MODELS ---
import 'package:relawan_kita/features/donation/data/models/campaign_model.dart';
import 'package:relawan_kita/features/emergency/data/models/reports_model.dart';
import 'package:relawan_kita/features/donation/data/models/donation_history_model.dart';
import 'package:relawan_kita/features/home/data/models/notification_model.dart';

class ApiService {
  // GANTI IP SESUAI KEBUTUHAN:
  final String baseUrl = "http://172.20.10.6:8000/api";

  // ===========================================================================
  // 1. AUTHENTICATION (Login, Register, Logout)
  // ===========================================================================

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

        await _saveLocalUser(token, user); // Helper Simpan Data
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

        await _saveLocalUser(token, user); // Auto Login
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

  // Cek apakah user login (Punya token)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token'); // True jika user, False jika tamu
  }

  // Helper Private untuk simpan data user (biar rapi)
  Future<void> _saveLocalUser(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_name', user['name']);
    await prefs.setString('user_email', user['email']);
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('user_nik', user['nik'] ?? '-');
    await prefs.setString('user_phone', user['phone'] ?? '-');

    // Simpan foto saat login/register juga
    if (user['photo_url'] != null) {
      await prefs.setString('user_photo', user['photo_url']);
    }
  }

  // ===========================================================================
  // 2. USER PROFILE (DIPERBAIKI UNTUK FOTO)
  // ===========================================================================

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'User',
      'email': prefs.getString('user_email') ?? '-',
      'nik': prefs.getString('user_nik') ?? '-',
      'phone': prefs.getString('user_phone') ?? '-',
      // Ambil URL foto dari penyimpanan lokal
      'photo_url': prefs.getString('user_photo') ?? '',
    };
  }

  // [PERBAIKAN UTAMA DISINI: MULTIPART REQUEST]
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String nik,
    File? imageFile, // Tambahan parameter file (Opsional)
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // Gunakan MultipartRequest agar bisa kirim File + Teks
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update-profile'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Data Teks
      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['nik'] = nik;

      // Data File (Jika user mengganti foto)
      if (imageFile != null) {
        var pic = await http.MultipartFile.fromPath('photo', imageFile.path);
        request.files.add(pic);
      }

      // Kirim Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Ambil data user terbaru dari respon server
        final data = jsonDecode(response.body);
        Map<String, dynamic> updatedUser = data['data']['user'];

        // Update data di HP agar sinkron
        await prefs.setString('user_name', updatedUser['name']);
        await prefs.setString('user_phone', updatedUser['phone'] ?? '');
        await prefs.setString('user_nik', updatedUser['nik'] ?? '');

        // Simpan URL Foto Baru (PENTING)
        if (updatedUser['photo_url'] != null) {
          await prefs.setString('user_photo', updatedUser['photo_url']);
        }

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
      }
      return [];
    } catch (e) {
      print("Error Get Campaigns: $e");
      return [];
    }
  }

  // ===========================================================================
  // 4. REPORTS (LAPORAN BENCANA)
  // ===========================================================================

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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reports'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['category'] = category;
      request.fields['urgency'] = urgency;
      request.fields['location_address'] = address;
      request.fields['description'] = description;
      request.fields['latitude'] = "-0.02"; // Dummy
      request.fields['longitude'] = "109.33"; // Dummy

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error Get My Reports: $e");
      return [];
    }
  }

  Future<bool> deleteReports(List<int> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/reports/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ids': ids}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete Reports: $e");
      return false;
    }
  }

  Future<bool> cancelReport(int reportId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/reports/$reportId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Cancel Report: $e");
      return false;
    }
  }

  // ===========================================================================
  // 5. OTHERS (DONATIONS)
  // ===========================================================================

  Future<String?> createDonation(int campaignId, int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/donate'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'campaign_id': campaignId.toString(),
          'amount': amount.toString(),
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data']['snap_token'];
      }
      return null;
    } catch (e) {
      print("Error Create Donation: $e");
      return null;
    }
  }

  Future<List<DonationHistoryModel>> getDonationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/donations/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => DonationHistoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error Get Donation History: $e");
      return [];
    }
  }

  // [BARU] AMBIL DATA UNTUK PETA (PUBLIC)
  Future<List<ReportModel>> getPublicReports() async {
    try {
      // Tidak perlu Header Authorization karena endpoint public
      final response = await http.get(Uri.parse('$baseUrl/reports/public'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error Get Map Data: $e");
      return [];
    }
  }

  // --- RESET PASSWORD (DEV MODE) ---
  Future<bool> resetPasswordDev(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password-dev'),
        body: {
          'email': email,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        headers: {'Accept': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Reset Password: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getWeather(double lat, double long) async {
    try {
      final url = "$baseUrl/weather?lat=$lat&lon=$long";
      print("Requesting Weather: $url"); // DEBUG 1

      final response = await http.get(Uri.parse(url));

      print("Weather Status: ${response.statusCode}"); // DEBUG 2
      print("Weather Body: ${response.body}"); // DEBUG 3

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error Weather API: $e"); // LIHAT INI DI CONSOLE
      return null;
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error Get Notifications: $e");
      return [];
    }
  }

  // --- KIRIM SOS ---
  Future<bool> sendSos(double lat, double long) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/reports/sos'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'latitude': lat.toString(), 'longitude': long.toString()},
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error SOS: $e");
      return false;
    }
  }
}
