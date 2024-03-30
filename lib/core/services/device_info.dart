import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DeviceData {
  Future<String> getDeviceName(context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? _deviceName;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      _deviceName = iosInfo.name;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      _deviceName = androidInfo.model;
    }
    return _deviceName;
  }

  Future<String> getStorageDirectory() async {
    // Get the directory for storing files
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
}
