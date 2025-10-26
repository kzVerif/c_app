import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> recent = [];
  bool scanning = false;
  bool loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadRecentCheckins();
  }

  Future<void> _loadRecentCheckins() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final res = await ApiService.getCheckinsByDevice(deviceId);

      final List<dynamic> data = res['data'] ?? [];

      // 🔹 เรียงจากใหม่สุดไปเก่าสุด (timestamp)
      data.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // 🔹 จำกัดแค่ 5 รายการแรก
      final limited = data.take(5).toList();

      setState(() {
        recent = limited.map((item) {
          final ts = DateTime.parse(item['timestamp']).toLocal();
          final formatted =
              "${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} "
              "${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}";
          return {
            'course': item['course_code'],
            'time': formatted,
            'status': item['status'],
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        recent = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('โหลดข้อมูลล้มเหลว: $e', style: GoogleFonts.kanit()),
        ),
      );
    } finally {
      setState(() => loadingHistory = false);
    }
  }

  Future<void> checkIn() async {
    setState(() => scanning = true);

    try {
      final deviceId = await DeviceService.getDeviceId();
      final macs = await BluetoothService.scanNearbyDevices();
      final res = await ApiService.checkIn(
        deviceId: deviceId,
        studentId: widget.user['student_id'],
        bluetoothDevices: macs,
      );

      setState(() => scanning = false);

      final bool success = res['zone'] != null;
      final String title = success
          ? "เช็คชื่อสำเร็จ 🎉"
          : "เช็คชื่อไม่สำเร็จ ❌";
      final String message = res['message'] ?? 'ไม่สามารถเช็คชื่อได้';
      final IconData icon = success
          ? Icons.check_circle_rounded
          : Icons.error_rounded;
      final Color iconColor = success
          ? Colors.greenAccent.shade400
          : Colors.redAccent.shade200;

      // ✅ Popup Modern
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 64, color: iconColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.kanit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      if (success) {
                        _loadRecentCheckins(); // ✅ รีโหลดกิจกรรมล่าสุด
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
    } catch (e) {
      setState(() => scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user['name'];
    final today = DateTime.now().toLocal().toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ระบบเช็คชื่อ",
          style: GoogleFonts.kanit(fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🧑‍🎓 โปรไฟล์
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.kanit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "วันที่ $today",
                      style: GoogleFonts.kanit(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🔵 ปุ่มเช็คชื่อ
            ElevatedButton.icon(
              onPressed: scanning ? null : checkIn,
              icon: const Icon(Icons.bluetooth_searching),
              label: scanning
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("เช็คชื่อ"),
            ),

            const SizedBox(height: 30),

            // 📋 หัวข้อกิจกรรม
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "กิจกรรมล่าสุด",
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 📦 โหลดข้อมูลกิจกรรมจาก API
            Expanded(
              child: loadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : (recent.isEmpty
                        ? Center(
                            child: Text(
                              "ยังไม่มีประวัติการเช็คชื่อ",
                              style: GoogleFonts.kanit(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: recent.length,
                            itemBuilder: (_, i) => Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.history,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  "รหัสวิชา: ${recent[i]['course'] ?? '-'}",
                                  style: GoogleFonts.kanit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "เวลา: ${recent[i]['time'] ?? '-'}",
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Text(
                                  recent[i]['status'] == "checked_in"
                                      ? "เข้าเรียน"
                                      : recent[i]['status'] == "late"
                                      ? "เข้าเรียนสาย"
                                      : "ไม่เข้าเรียน",
                                  style: GoogleFonts.kanit(
                                    fontSize: 18,
                                    color: recent[i]['status'] == "checked_in"
                                        ? Colors.green
                                        : recent[i]['status'] == "late"
                                        ? Colors.orange
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          )),
            ),
          ],
        ),
      ),
    );
  }
}
