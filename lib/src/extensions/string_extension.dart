extension StringX on String {
  /// Removes leading and trailing empty lines from the string.
  Iterable<String> removeWrapping() sync* {
    final lines = split('\n');
    if (lines.isEmpty) return;

    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines.removeAt(0);
    }

    if (lines.isEmpty) return;

    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }

    for (final lint in lines) {
      yield lint.trim();
    }
  }

  String relativeTo(String dirPath) {
    var filePath = replaceFirst(dirPath, '');

    final nonLetter = RegExp(r'[^a-zA-Z0-9_]');
    while (filePath.isNotEmpty && nonLetter.hasMatch(filePath[0])) {
      filePath = filePath.substring(1);
    }

    return filePath;
  }
}
