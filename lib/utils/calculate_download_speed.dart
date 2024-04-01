int updateDownloadSpeed(receivedBytes, DateTime startTime) {
  DateTime now = DateTime.now();
  Duration duration = now.difference(startTime);
  double speed = receivedBytes / duration.inSeconds;
  if (!speed.isNaN && !speed.isInfinite) {
    return speed.toInt();
  } else {
    return 0;
  }
}
