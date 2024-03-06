import 'package:barreler/handlers/build_handler.dart';
import 'package:barreler/src/barrel.dart';
import 'package:barreler/src/find_settings.dart';
import 'package:barreler/src/settings/default_settings.dart';
import 'package:barreler/src/settings/directory_settings.dart';
import 'package:barreler/src/settings/settings.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

void main() {
  group('$BuildHandler', () {
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

    group('#getBarrels', () {
      late BuildHandler handler;

      setUp(() {
        handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: null,
          exitOnChange: false,
        );
      });

      test('return simple generator', () async {
        createStructure(
          dirs: ['lib'],
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib',
          fileName: 'index',
        );

        final settings = Settings(
          dirs: [dirSettings],
        );

        final barrelers = await handler.getBarrels(settings);

        expect(barrelers, hasLength(1));

        final barreler = barrelers.first;
        final expected = Barrel(
          baseSettings: settings,
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        expect(barreler, expected);
      });

      test('can find matching dirs', () async {
        createStructure(
          dirs: ['lib/src', 'lib/models'],
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/*',
          fileName: 'index',
        );

        final settings = Settings(
          dirs: [dirSettings],
        );

        final barrelers = await handler.getBarrels(settings);

        expect(barrelers, hasLength(2));

        final expected = [
          Barrel(
            baseSettings: settings,
            dirSettings: dirSettings.changePath('lib/models'),
            fs: fs,
            logger: mockLogger,
          ),
          Barrel(
            baseSettings: settings,
            dirSettings: dirSettings.changePath('lib/src'),
            fs: fs,
            logger: mockLogger,
          ),
        ];

        expect(barrelers, expected);
      });

      test('sorts dirs by length', () async {
        createStructure(
          dirs: ['lib/src/models'],
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/**',
          fileName: 'index',
        );

        final settings = Settings(
          dirs: [dirSettings],
        );

        final barrelers = await handler.getBarrels(settings);

        expect(barrelers, hasLength(2));

        final expected = [
          Barrel(
            baseSettings: settings,
            dirSettings: dirSettings.changePath('lib/src/models'),
            fs: fs,
            logger: mockLogger,
          ),
          Barrel(
            baseSettings: settings,
            dirSettings: dirSettings.changePath('lib/src'),
            fs: fs,
            logger: mockLogger,
          ),
        ];

        expect(barrelers, expected);
      });
    });

    group('#getConfigPath', () {
      test('fails if no config file is found', () async {
        createStructure();

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: null,
          exitOnChange: false,
        );

        final (path, exitCode) = await handler.getConfigPath();

        expect(path, isNull);
        expect(exitCode, isNotNull);
      });

      test('can read default path', () async {
        createStructure(
          files: [FindSettings.defaultPath],
        );

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: null,
          exitOnChange: false,
        );

        final (path, exitCode) = await handler.getConfigPath();

        expect(path, endsWith(FindSettings.defaultPath));
        expect(exitCode, isNull);
      });

      test('can read provided path', () async {
        createStructure(
          files: ['other.yaml'],
        );

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: 'other.yaml',
          exitOnChange: false,
        );

        final (path, exitCode) = await handler.getConfigPath();

        expect(path, endsWith('other.yaml'));
        expect(exitCode, isNull);
      });

      test('changes cwd when cwd is not with config file', () async {
        final beforeCwd = fs.currentDirectory.path;

        createStructure(
          dirs: ['lib'],
          files: ['other.yaml'],
        );

        fs.currentDirectory = fs.directory('lib');

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: 'other.yaml',
          exitOnChange: false,
        );

        final (path, exitCode) = await handler.getConfigPath();

        expect(path, endsWith('other.yaml'));
        expect(exitCode, isNull);

        expect(fs.currentDirectory.path, beforeCwd);
      });
    });

    group('#createBarrelFiles', () {
      test('can create barrel files', () async {
        createStructure(
          dirs: ['lib/src'],
          files: ['lib/src/file.dart'],
        );

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: null,
          exitOnChange: false,
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
          fileName: 'index',
        );

        final barrels = [
          Barrel(
            baseSettings: Settings(
              dirs: [dirSettings],
            ),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          ),
        ];

        await handler.createBarrelFiles(barrels);

        final barrelFile = fs.file('lib/src/index.dart');
        expect(barrelFile.existsSync(), isTrue);
      });

      test('skips creation when no files are found', () async {
        createStructure(
          dirs: ['lib/src'],
        );

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: null,
          exitOnChange: false,
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
          fileName: 'index',
        );

        final barrels = [
          Barrel(
            baseSettings: Settings(
              dirs: [dirSettings],
            ),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          ),
        ];

        await handler.createBarrelFiles(barrels);

        final barrelFile = fs.file('lib/src/index.dart');
        expect(barrelFile.existsSync(), isFalse);
      });

      test('fails when changes are detected when exitOnChange is true',
          () async {
        createStructure(
          dirs: ['lib/src'],
          files: ['lib/src/file.dart'],
        );

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: null,
          exitOnChange: true,
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
          fileName: 'index',
        );

        final barrels = [
          Barrel(
            baseSettings: Settings(
              dirs: [dirSettings],
              defaultSettings: DefaultSettings(disclaimer: 'blah'),
            ),
            dirSettings: dirSettings,
            fs: fs,
            logger: mockLogger,
          ),
        ];

        final success = await handler.createBarrelFiles(barrels);

        expect(success, isFalse);

        final barrelFile = fs.file('lib/src/index.dart');
        expect(barrelFile.existsSync(), isFalse);
      });

      test('succeeds when no changes are detected when exitOnChange is true',
          () async {
        createStructure(
          dirs: ['lib/src'],
          files: ['lib/src/file.dart'],
        );

        final handler = BuildHandler(
          logger: mockLogger,
          fs: fs,
          settings: FindSettings(fs: fs),
          providedConfigPath: null,
          exitOnChange: true,
        );

        final dirSettings = DirectorySettings(
          dirPath: 'lib/src',
          fileName: 'index',
        );

        final barrel = Barrel(
          baseSettings: Settings(
            dirs: [dirSettings],
          ),
          dirSettings: dirSettings,
          fs: fs,
          logger: mockLogger,
        );

        final seed = await barrel.create(allowChange: true);

        expect(seed, isNull); //successfully created

        final barrels = [barrel];

        final success = await handler.createBarrelFiles(barrels);

        expect(success, isTrue);

        final barrelFile = fs.file('lib/src/index.dart');
        expect(barrelFile.existsSync(), isTrue);
      });
    });
  });
}
