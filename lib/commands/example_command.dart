import 'package:args/command_runner.dart';
import 'package:barreler/src/settings/default_settings.dart';
import 'package:barreler/src/settings/directory_settings.dart';
import 'package:barreler/src/settings/export_settings.dart';
import 'package:barreler/src/settings/settings.dart';
import 'package:file/file.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:mason_logger/mason_logger.dart';

class ExampleCommand extends Command<int> {
  ExampleCommand({
    required this.fileSystem,
    required this.logger,
  });

  final FileSystem fileSystem;
  final Logger logger;

  @override
  String get name => 'example';

  List<String> get aliases => ['init', 'create', 'new'];

  @override
  String get description => 'An example command';

  static String createExampleContent() {
    final settings = Settings(
      include: ['**/*.dart'],
      exclude: ['**/*.g.dart'],
      defaultSettings: DefaultSettings(
        fileName: '# defaults to directory name',
      ),
      dirs: [
        DirectorySettings(
          dirPath: 'lib',
          exports: [
            ExportSettings(
              export: 'package:equatable/equatable.dart',
              show: ['Equatable'],
            ),
          ],
          include: [
            ExportSettings(
              export: 'src/letters.dart',
              hide: ['A', 'B', 'C'],
            ),
          ],
          exclude: ['src/numbers.dart'],
        ),
      ],
    );

    final json = settings.toJson();

    json.remove('line_break');

    json['dirs'][0]['include'] = [
      'src/loz.dart',
      // ignore: not_iterable_spread
      ...json['dirs'][0]['include'],
    ];
    json['dirs'][0]['exports'] = [
      'package:mario/mario.dart',
      // ignore: not_iterable_spread
      ...json['dirs'][0]['exports'],
    ];

    // make sure that it can still be parsed
    Settings.fromJson(json);

    final yaml = json2yaml(json);

    return yaml;
  }

  Future<String?> projectRoot() async {
    var dir = fileSystem.currentDirectory;

    while (true) {
      if (await dir.childFile('pubspec.yaml').exists()) {
        return dir.path;
      }

      if (dir.parent.path == dir.path) {
        break;
      }

      dir = dir.parent;
    }

    return null;
  }

  @override
  Future<int> run() async {
    final root = await projectRoot();

    if (root == null) {
      logger.err('Could not find project root');
      return 1;
    }

    final content = createExampleContent();

    final file = fileSystem.file(fileSystem.path.join(root, 'barreler.yaml'));

    if (await file.exists()) {
      final eraseFile = await logger.confirm(
        'The barreler config file already exists, do you want to overwrite it?',
      );

      if (!eraseFile) {
        logger.info('Aborted');
        return 0;
      }
    }

    final done = logger.progress('Creating barreler.yaml');

    try {
      await file.writeAsString(content);

      done.complete('barreler.yaml created');
    } catch (e) {
      done.fail('Failed to create barreler.yaml');
      logger.err(e.toString());

      return 1;
    }

    return 0;
  }
}
