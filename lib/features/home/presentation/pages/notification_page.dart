import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:relawan_kita/core/services/api_service.dart';
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/notification_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    bool login = await ApiService().isLoggedIn();
    setState(() => _isGuest = !login);
  }

  @override
  Widget build(BuildContext context) {
    // [TAMPILAN TAMU]
    if (_isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifikasi"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Remix.notification_off_line, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text("Tidak ada notifikasi", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false),
                child: const Text("Login untuk melihat update"),
              )
            ],
          ),
        ),
      );
    }

    // [TAMPILAN USER]
    final List<Map<String, dynamic>> notifications = [
      {"title": "PERINGATAN DINI: Siaga Banjir", "body": "Debit air di Bendungan A meningkat drastis...", "time": "Baru saja", "type": "alert"},
      {"title": "Laporan Diterima", "body": "Laporan kerusakan jalan yang Anda kirimkan telah kami terima.", "time": "10 menit lalu", "type": "info"},
      {"title": "Donasi Berhasil Disalurkan", "body": "Terima kasih! Bantuan dana Anda telah disalurkan.", "time": "1 jam lalu", "type": "success"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Notifikasi", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, leading: IconButton(icon: const Icon(Remix.arrow_left_line), onPressed: () => Navigator.pop(context))),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isAlert = item['type'] == 'alert';
          return Container(
            color: isAlert ? Colors.red.withOpacity(0.05) : Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isAlert ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1), shape: BoxShape.circle), child: _getIcon(item['type'])),
              title: Text(item['title'], style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: isAlert ? Colors.red : Colors.black87)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text(item['body'], maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: 13)), const SizedBox(height: 8), Text(item['time'], style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey))]),
              isThreeLine: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationDetailPage(title: item['title'], body: item['body'], time: item['time'], type: item['type']))),
            ),
          );
        },
      ),
    );
  }

  Widget _getIcon(String type) {
    switch (type) {
      case 'alert': return const Icon(Remix.alarm_warning_fill, color: Colors.red, size: 24);
      case 'success': return const Icon(Remix.checkbox_circle_fill, color: Colors.green, size: 24);
      default: return const Icon(Remix.information_fill, color: Colors.blue, size: 24);
    }
  }
}