import 'package:dio/dio.dart';

class TransferUpdate {
  final String filename;
  final String path;
  final int count;
  final int total;
  final bool completed;
  final bool failed;
  final bool receiving;
  final int id;
  int speed;
  DateTime startTime;
  final CancelToken? cancelToken;
  TransferUpdate({
    required this.filename,
    required this.path,
    required this.count,
    required this.total,
    required this.completed,
    required this.failed,
    required this.receiving,
    this.speed = 0,
    DateTime? startTime,
    required this.id,
    required this.cancelToken,
  }) : startTime = startTime ?? DateTime.now();

  updateSpeed(newSpeed) {
    speed = newSpeed;
  }

  updateStartTime(DateTime newStartTime) {
    startTime = newStartTime;
  }
}

class DownloadQueueItem {
  String url;
  bool downloading;
  int id;
  final String filename;
  final String path;
  final CancelToken cancelToken;
  DownloadQueueItem({
    required this.url,
    required this.downloading,
    required this.id,
    required this.filename,
    required this.path,
    required this.cancelToken,
  });
}
