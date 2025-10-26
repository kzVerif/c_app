import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return info.id ?? info.device ?? "unknown-android";
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        // ใช้ identifierForVendor บน iOS
        return info.identifierForVendor ?? "unknown-ios";
      } else {
        return "unknown-platform";
      }
    } catch (e) {
      debugPrint("❌ Error getting device ID: $e");
      return "unknown-device";
    }
  }
}
