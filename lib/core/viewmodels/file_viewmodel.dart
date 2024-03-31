import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sharer/core/data/repository/file_repository.dart';

class FileViewmodel extends ChangeNotifier {
  FileRepository _repo = FileRepository();
  List<String> _selectedItems = [];
  List<String> get selectedItems => _selectedItems;
  setSelectedItems(File item) {
    if (_selectedItems.contains(item.path)) {
      _selectedItems.remove(item.path);
    } else {
      _selectedItems.add(item.path);
    }

    notifyListeners();
  }

  clearItems() {
    _selectedItems.clear();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> loadDocuments() async {
    return _repo.loadDocuments();
  }
}
