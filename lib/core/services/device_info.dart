import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId;
    try {
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

        deviceId = iosInfo.identifierForVendor ?? "";
      } else {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        deviceId = androidInfo.id;
      }
      return deviceId;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "";
    }
  }

  Future<String> getStorageDirectory() async {
    // Get the directory for storing files
    var directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }

    return directory.path;
  }
}
