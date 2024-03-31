String formatBytes(int bytes) {
  double kb = bytes / 1024;
  double mb = kb / 1024;
  double gb = mb / 1024;

  if (gb >= 1) {
    return '${gb.toStringAsFixed(0)} GB';
  } else if (mb >= 1) {
    return '${mb.toStringAsFixed(0)} MB';
  } else {
    return '${kb.toStringAsFixed(0)} KB';
  }
}
