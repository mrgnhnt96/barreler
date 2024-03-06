import 'package:file/file.dart';
import 'package:path/path.dart' as p;

class FindSettings {
  FindSettings({
    required this.fs,
  });

  static const defaultPath = 'barreler.yaml';

  final FileSystem fs;

  Future<String?> path(String? providedPath) async {
    var parent = fs.currentDirectory.path;

    String? tryPath(String? fileName) {
      if (fileName == null) {
        return null;
      }

      final file = fs.file(p.join(parent, fileName));

      if (file.existsSync()) {
        return file.path;
      }

      return null;
    }

    // travel up the tree until we find the file
    // or we reach the root
    while (true) {
      final defaultFile = tryPath(defaultPath);
      final providedFile = tryPath(providedPath);

      if ((providedFile ?? defaultFile) != null) {
        return providedFile ?? defaultFile;
      }

      final newParent = fs.directory(parent).parent.path;

      if (newParent == parent) {
        break;
      }

      parent = newParent;
    }

    return null;
  }
}
