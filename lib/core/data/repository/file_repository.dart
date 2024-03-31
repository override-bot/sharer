import 'dart:io';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class FileRepository {
  Future<List<Map<String, dynamic>>> loadDocuments() async {
    List<Map<String, dynamic>> documentGroups = [];

    var status = await Permission.storage.request();
    if (status.isGranted) {
      //Directory directory = Directory('/storage/emulated/0/Documents');
      Directory directory = Directory('/storage/emulated/0/Download');

      List<FileSystemEntity> files = directory
          .listSync(recursive: true)
          .where((element) =>
              element.path.split('.').last.toLowerCase() == "pdf" ||
              element.path.split('.').last.toLowerCase() == "doc" ||
              element.path.split('.').last.toLowerCase() == "docx")
          .toList();
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      for (var file in files) {
        if (file is File) {
          DateTime fileCreationDate = file.lastModifiedSync();
          String monthYear = DateFormat('MMMM y').format(fileCreationDate);

          int existingIndex = documentGroups
              .indexWhere((group) => group['monthYear'] == monthYear);
          if (existingIndex != -1) {
            documentGroups[existingIndex]['documents'].add(file);
          } else {
            documentGroups.add({
              'monthYear': monthYear,
              'documents': [file],
            });
          }
        }
      }
    }
    return documentGroups;
  }
}
