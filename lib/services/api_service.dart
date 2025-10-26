import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://6qdt0zs2-80.asse.devtunnels.ms/api';

  static Future<Map<String, dynamic>> login(
    String studentId,
    String password,
    String deviceId,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_id': studentId,
        'password': password,
        'device_id': deviceId,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String studentId,
    String password,
    String rePassword,
    String deviceId,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'student_id': studentId,
        'password': password,
        'rePassword': rePassword,
        'device_id': deviceId,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> checkIn({
    required String deviceId,
    required String studentId,
    required List<String> bluetoothDevices,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/checkins'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'student_id': studentId,
          'bluetooth_devices': bluetoothDevices,
          'timestamp': now,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        // ✅ สำเร็จ
        return data;
      } else if (res.statusCode >= 400 && res.statusCode < 500) {
        // ⚠️ client error เช่น body ผิด, ข้อมูลไม่ครบ
        return {
          'message':
              data['message'] ?? '⚠️ ร้องขอไม่ถูกต้อง (${res.statusCode})',
          'detail': data,
        };
      } else if (res.statusCode >= 500) {
        // ❌ server error
        return {'message': '❌ เซิร์ฟเวอร์มีปัญหา กรุณาลองใหม่ภายหลัง'};
      } else {
        return {'message': '⚠️ ไม่ทราบสถานะ (${res.statusCode})'};
      }
    } catch (e) {
      // 🌐 network / tunnel error
      return {'message': '🚫 ไม่สามารถเชื่อมต่อ API ได้\n($e)'};
    }
  }

  static Future<Map<String, dynamic>> getCheckinsByDevice(
    String deviceId,
  ) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/checkins/$deviceId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {'message': data['message'], 'data': data['data'] ?? []};
      } else if (res.statusCode == 500) {
        return {
          'message': '❌ เซิร์ฟเวอร์มีปัญหา กรุณาลองใหม่ภายหลัง',
          'data': [],
        };
      } else {
        final data = jsonDecode(res.body);
        return {
          'message': data['message'] ?? '⚠️ เกิดข้อผิดพลาดไม่ทราบสาเหตุ',
          'data': [],
        };
      }
    } catch (e) {
      return {'message': '🚫 ไม่สามารถเชื่อมต่อ API ได้\n($e)', 'data': []};
    }
  }
}
