import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static Future<List<String>> scanNearbyDevices() async {
    List<String> macList = [];

    // ✅ ขอ permission ก่อน
    await _requestPermissions();

    // ✅ ตรวจว่าบลูทูธเปิดไหม
    final isOn = await FlutterBluePlus.isOn;
    if (!isOn) {
      throw Exception("กรุณาเปิด Bluetooth ก่อนใช้งาน");
    }

    // ✅ เริ่มสแกน (5 วินาที)
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    print("เริ่มสแกน Bluetooth...");

    // ✅ ฟังผลการสแกน
    StreamSubscription? subscription;
    subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final mac = result.device.remoteId.str;
        if (!macList.contains(mac)) {
          macList.add(mac);
          print(
            "พบอุปกรณ์: ${result.device.platformName} (${result.device.remoteId.str})",
          );
        }
      }
    });

    // ✅ รอ 5 วินาทีแล้วหยุดสแกน
    await Future.delayed(const Duration(seconds: 5));
    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    print("สแกนเสร็จสิ้น พบ ${macList.length} อุปกรณ์");

    return macList;
  }

  static Future<void> _requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    final statuses = await permissions.request();

    for (final p in permissions) {
      final status = await p.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        throw Exception(
          'กรุณาอนุญาตสิทธิ์ Bluetooth และ Location เพื่อสแกนอุปกรณ์',
        );
      }
    }
  }
}
