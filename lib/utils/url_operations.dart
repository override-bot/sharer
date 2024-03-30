import 'dart:math';

import 'constants.dart';

class UrlOperations {
  final String msg;
  UrlOperations({required this.msg});
  String getUrl() {
    String url = msg.toString().split(fileSizeSeperation).last;
    return url;
  }

  int getFileSize() {
    int size = int.tryParse(msg
            .toString()
            .replaceFirst(fileTransferCode, "")
            .split(fileSizeSeperation)
            .first) ??
        0;
    return size;
  }

  int getId() {
    String url = getUrl();
    int id = int.tryParse(url.split("&id=").last) ?? Random().nextInt(10000);
    return id;
  }

  String getFileName() {
    String url = getUrl();
    String name =
        url.split("/").last.replaceFirst("&id=${url.split("&id=").last}", "");
    return name;
  }
}
