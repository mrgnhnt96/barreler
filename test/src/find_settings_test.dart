import 'package:barreler/src/find_settings.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

void main() {
  group('$FindSettings', () {
    late FileSystem fs;

    setUp(() {
      fs = MemoryFileSystem();
    });

    void createStructure({
      List<String> dirs = const [],
      List<String> files = const [],
    }) {
      for (final dir in dirs) {
        fs.directory(dir).createSync(recursive: true);
      }

      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }
    }

    test('finds default file in current directory', () async {
      createStructure(files: [FindSettings.defaultPath]);

      final settings = FindSettings(fs: fs);

      final path = await settings.path(null);

      expect(path, isNotNull);
      expect(path, endsWith(FindSettings.defaultPath));
    });

    test('finds provided file in current directory', () async {
      createStructure(files: ['foo.yaml']);

      final settings = FindSettings(fs: fs);

      final path = await settings.path('foo.yaml');

      expect(path, isNotNull);
      expect(path, endsWith('foo.yaml'));
    });

    test('finds default file in parent directory', () async {
      createStructure(dirs: ['foo'], files: [FindSettings.defaultPath]);

      fs.currentDirectory = fs.directory('foo');

      final settings = FindSettings(fs: fs);

      final path = await settings.path(null);

      expect(path, isNotNull);
      expect(path, endsWith(FindSettings.defaultPath));
    });

    test('finds provided file in parent directory', () async {
      createStructure(dirs: ['foo'], files: ['bar.yaml']);

      fs.currentDirectory = fs.directory('foo');

      final settings = FindSettings(fs: fs);

      final path = await settings.path('bar.yaml');

      expect(path, isNotNull);
      expect(path, endsWith('bar.yaml'));
    });

    test('returns null if default file not found', () async {
      createStructure(dirs: ['foo']);

      fs.currentDirectory = fs.directory('foo');

      final settings = FindSettings(fs: fs);

      final path = await settings.path(null);

      expect(path, isNull);
    });

    test('returns null if provided file not found', () async {
      createStructure(dirs: ['foo']);

      fs.currentDirectory = fs.directory('foo');

      final settings = FindSettings(fs: fs);

      final path = await settings.path('bar.yaml');

      expect(path, isNull);
    });
  });
}
