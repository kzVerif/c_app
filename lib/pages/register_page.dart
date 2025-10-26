import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final studentCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final rePassCtrl = TextEditingController();
  bool loading = false;

  Future<void> handleRegister() async {
    setState(() => loading = true);
    final deviceId = await DeviceService.getDeviceId();
    final res = await ApiService.register(
      nameCtrl.text,
      emailCtrl.text,
      studentCtrl.text,
      passCtrl.text,
      rePassCtrl.text,
      deviceId,
    );
    setState(() => loading = false);

    final bool success = res['message'].toString().contains('สำเร็จ');
    final String title = success ? "สมัครสมาชิกสำเร็จ 🎉" : "สมัครสมาชิกไม่สำเร็จ ❌";
    final IconData icon = success ? Icons.check_circle_rounded : Icons.error_rounded;
    final Color iconColor = success ? Colors.greenAccent.shade400 : Colors.redAccent.shade200;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🟢 Icon
                Container(
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
                  res['message'] ?? 'เกิดข้อผิดพลาดไม่ทราบสาเหตุ',
                  style: GoogleFonts.kanit(fontSize: 16, color: Colors.grey[700]),
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
                        MaterialPageRoute(builder: (_) => const LoginPage()),
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
      appBar: AppBar(
        title: Text('สมัครสมาชิก', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 10),
                Text(
                  "สร้างบัญชีใหม่",
                  style: GoogleFonts.kanit(
                      fontSize: 26, fontWeight: FontWeight.w600, color: Colors.blue[800]),
                ),
                const SizedBox(height: 20),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ชื่อ-นามสกุล')),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'อีเมล')),
                const SizedBox(height: 12),
                TextField(controller: studentCtrl, decoration: const InputDecoration(labelText: 'รหัสนิสิต')),
                const SizedBox(height: 12),
                TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'รหัสผ่าน')),
                const SizedBox(height: 12),
                TextField(controller: rePassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่าน')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('สมัครสมาชิก', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
