import 'package:barreler/src/barrel.dart';
import 'package:barreler/src/settings/directory_settings.dart';
import 'package:barreler/src/settings/export_settings.dart';
import 'package:barreler/src/settings/settings.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

void main() {
  group('$Barrel', () {
    late FileSystem fs;
    late Logger mockLogger;

    setUp(() {
      fs = MemoryFileSystem();
      mockLogger = _MockLogger();

      when(() => mockLogger.progress(any(), options: any(named: 'options')))
          .thenAnswer((_) => _MockProgress());
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

    group('#findFiles', () {
      test('find files without barrel file', () {
        createStructure(
          dirs: ['lib/src'],
          files: [
            'lib/src/foo.dart',
            'lib/src/bar.dart',
            'lib/src/index.dart',
          ],
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
          fileName: 'index',
        );

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final files = barrel.findFiles().toList();

        expect(files, hasLength(2));
        expect(files, isNot(contains('lib/src/index.dart')));
      });

      test('ignores directories', () {
        createStructure(
          dirs: ['lib/src', 'lib/src/foo'],
          files: [
            'lib/src/bar.dart',
          ],
        );

        final dirSettings = DirectorySettings(dirPath: 'lib/src');

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final files = barrel.findFiles().toList();

        expect(files, hasLength(1));
        expect(files, isNot(contains('lib/src/foo')));
      });

      test('ignores non-dart files', () {
        createStructure(
          dirs: ['lib/src'],
          files: [
            'lib/src/bar.ts',
            'lib/src/baz.dart',
          ],
        );

        final dirSettings = DirectorySettings(dirPath: 'lib/src');

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final files = barrel.findFiles().toList();

        expect(files, hasLength(1));
        expect(files, isNot(contains('lib/src/bar.ts')));
      });
    });

    group('#filterFiles', () {
      test('includes all files by default', () {
        final dirSettings = DirectorySettings(dirPath: 'lib/src');

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final files = barrel.filterFiles([
          'lib/src/foo.dart',
          'lib/src/bar.dart',
        ]).toList();

        expect(files, hasLength(2));
      });

      test('includes files that match the end of the pattern', () {
        final dirSettings = DirectorySettings(
          dirPath: 'packages/application/lib',
          include: [
            ExportSettings(export: '**_bloc.dart'),
            ExportSettings(
              export: 'setup/setup.dart',
              show: ['setup'],
            ),
          ],
        );

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final files = barrel.filterFiles([
          'packages/application/lib/blocs/foo_bloc.dart',
          'packages/application/lib/setup/setup.dart',
        ]).toList();

        expect(files, hasLength(2));
      });

      group('excludes file when', () {
        test('base settings has matching pattern', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
          );

          final barrel = Barrel(
            baseSettings: Settings(
              dirs: [dirSettings],
              exclude: ['**/bar.dart'],
            ),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final files = barrel.filterFiles([
            'lib/src/foo.dart',
            'lib/src/bar.dart',
          ]).toList();

          expect(files, hasLength(1));
          expect(files, isNot(contains('lib/src/bar.dart')));
        });

        test('dir settings has matching pattern', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
            exclude: ['**/bar.dart'],
          );

          final barrel = Barrel(
            baseSettings: Settings(dirs: [dirSettings]),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final files = barrel.filterFiles([
            'lib/src/foo.dart',
            'lib/src/bar.dart',
          ]).toList();

          expect(files, hasLength(1));
          expect(files, isNot(contains('lib/src/bar.dart')));
        });
      });

      group('includes file when', () {
        test('base settings has matching pattern', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
          );

          final barrel = Barrel(
            baseSettings: Settings(
              dirs: [dirSettings],
              include: ['**/foo.dart'],
            ),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final files = barrel.filterFiles([
            'lib/src/foo.dart',
            'lib/src/bar.dart',
          ]).toList();

          expect(files, hasLength(1));
          expect(files, isNot(contains('lib/src/bar.dart')));
        });

        test('dir settings has matching pattern', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
            include: [
              ExportSettings(export: '**/foo.dart'),
            ],
          );

          final barrel = Barrel(
            baseSettings: Settings(dirs: [dirSettings]),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final files = barrel.filterFiles([
            'lib/src/foo.dart',
            'lib/src/bar.dart',
          ]).toList();

          expect(files, hasLength(1));
          expect(files, isNot(contains('lib/src/bar.dart')));
        });
      });
    });

    group('#exports', () {
      test('create general export', () {
        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
        );

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final exports = barrel.exports([
          'lib/src/foo.dart',
        ]);

        expect(exports, hasLength(1));
        expect(exports, ["export 'foo.dart';"]);
      });

      group('adds show to end of export when provided', () {
        test('as relative path', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
            include: [
              ExportSettings(
                export: 'foo.dart',
                show: ['Foo'],
              ),
            ],
          );

          final barrel = Barrel(
            baseSettings: Settings(dirs: [dirSettings]),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final exports = barrel.exports([
            'lib/src/foo.dart',
          ]).toList();

          expect(exports, hasLength(1));
          expect(exports, ["export 'foo.dart' show Foo;"]);
        });

        test('as absolute path', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
            include: [
              ExportSettings(
                export: 'lib/src/foo.dart',
                show: ['Foo'],
              ),
            ],
          );

          final barrel = Barrel(
            baseSettings: Settings(dirs: [dirSettings]),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final exports = barrel.exports([
            'lib/src/foo.dart',
          ]).toList();

          expect(exports, hasLength(1));
          expect(exports, ["export 'foo.dart' show Foo;"]);
        });
      });

      group('adds hide to end of export when provided', () {
        test('as relative path', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
            include: [
              ExportSettings(
                export: 'foo.dart',
                hide: ['Foo'],
              ),
            ],
          );

          final barrel = Barrel(
            baseSettings: Settings(dirs: [dirSettings]),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final exports = barrel.exports([
            'lib/src/foo.dart',
          ]).toList();

          expect(exports, hasLength(1));
          expect(exports, ["export 'foo.dart' hide Foo;"]);
        });

        test('as absolute path', () {
          final dirSettings = DirectorySettings(
            dirPath: 'lib/src',
            include: [
              ExportSettings(
                export: 'lib/src/foo.dart',
                hide: ['Foo'],
              ),
            ],
          );

          final barrel = Barrel(
            baseSettings: Settings(dirs: [dirSettings]),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          );

          final exports = barrel.exports([
            'lib/src/foo.dart',
          ]).toList();

          expect(exports, hasLength(1));
          expect(exports, ["export 'foo.dart' hide Foo;"]);
        });
      });
    });

    group('#content', () {
      test('create barrel content', () {
        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
        );

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final disclaimer = 'disclaimer';
        final comments = 'comment';
        final externalExports = "export 'foo.dart';";
        final internalExports = "export 'bar.dart';";

        final content = barrel.content(
          disclaimer: [disclaimer],
          comments: [comments],
          externalExports: [externalExports],
          internalExports: [internalExports],
        )?.join('\n');

        expect(content, isNotNull);

        for (final item in [
          disclaimer,
          comments,
          externalExports,
          internalExports,
        ]) {
          expect(content, contains(item));
        }
      });

      test('returns null if no exports are provided', () {
        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
        );

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final content = barrel.content(
          disclaimer: ['disclaimer'],
          comments: ['comment'],
          externalExports: [],
          internalExports: [],
        );

        expect(content, isNull);
      });
    });

    group('#create', () {
      test('successfully creates file', () async {
        createStructure(
          dirs: ['lib/src'],
          files: [
            'lib/src/foo.dart',
            'lib/src/bar.dart',
          ],
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
          fileName: 'index',
        );

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final result = await barrel.create(allowChange: true);

        final file = fs.file('lib/src/index.dart');

        expect(result, isNull);
        expect(file.existsSync(), isTrue);
      });

      test('does not modify file when allow change is false', () async {
        createStructure(
          dirs: ['lib/src'],
          files: [
            'lib/src/foo.dart',
            'lib/src/bar.dart',
          ],
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
        );

        final barrel = Barrel(
          baseSettings: Settings(dirs: [dirSettings]),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final result = await barrel.create(allowChange: false);

        final file = fs.file('lib/src/index.dart');

        expect(result, isNotNull);
        expect(file.existsSync(), isFalse);
      });
    });
  });
}
