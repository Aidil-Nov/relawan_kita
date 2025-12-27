import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Lupa Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Remix.lock_password_line, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Masukkan email Anda, kami akan mengirimkan link reset password.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email Terdaftar",
                prefixIcon: const Icon(Remix.mail_send_line),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Logic kirim email
                  Navigator.pop(context);
                },
                child: const Text("KIRIM LINK"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}