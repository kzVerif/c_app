import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final studentIdCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  Future<void> handleLogin() async {
    setState(() => loading = true);
    final deviceId = await DeviceService.getDeviceId();
    final res = await ApiService.login(
      studentIdCtrl.text,
      passwordCtrl.text,
      deviceId,
    );
    setState(() => loading = false);

    final bool success = res['user'] != null;
    final String title = success ? "เข้าสู่ระบบสำเร็จ" : "เข้าสู่ระบบไม่สำเร็จ";
    final String message = res['message'] ?? 'เกิดข้อผิดพลาดไม่ทราบสาเหตุ';
    final IconData icon = success
        ? Icons.check_circle_rounded
        : Icons.error_rounded;
    final Color iconColor = success
        ? Colors.greenAccent.shade400
        : Colors.redAccent.shade200;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🟢 Animated Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 64, color: iconColor),
                ),
                const SizedBox(height: 20),

                // 🧭 Title
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // 📄 Message
                Text(
                  message,
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 🌈 Modern Gradient Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (success) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(user: res['user']),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: success
                            ? [Colors.blueAccent, Colors.lightBlueAccent]
                            : [Colors.redAccent, Colors.orangeAccent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "ตกลง",
                        style: GoogleFonts.kanit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "เข้าสู่ระบบ",
                    style: GoogleFonts.kanit(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: studentIdCtrl,
                    decoration: const InputDecoration(labelText: 'รหัสนิสิต'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loading ? null : handleLogin,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('เข้าสู่ระบบ'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: Text(
                      "ยังไม่มีบัญชี? สมัครสมาชิก",
                      style: GoogleFonts.kanit(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
