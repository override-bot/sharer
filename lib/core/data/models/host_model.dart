// ignore_for_file: prefer_const_constructors, prefer_collection_literals

import 'dart:convert';

class HostModel {
  String ipAddress;
  String deviceName;
  int port;

  HostModel({
    required this.deviceName,
    required this.ipAddress,
    required this.port,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      deviceName: json['deviceName'],
      ipAddress: json['ipAddress'],
      port: json['port'],
    );
  }

  factory HostModel.fromString(String str) {
    return HostModel.fromJson(jsonDecode(str));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['deviceName'] = deviceName;
    data['ipAddress'] = ipAddress;
    data['port'] = port;
    return data;
  }

  String encode() {
    return jsonEncode(this.toJson());
  }
}
