import 'package:args/command_runner.dart';
import 'package:barreler/handlers/build_handler.dart';
import 'package:barreler/src/find_settings.dart';
import 'package:file/file.dart';
import 'package:mason_logger/mason_logger.dart';

class BuildCommand extends Command<int> {
  BuildCommand({
    required this.settings,
    required this.fs,
    required this.logger,
  }) {
    argParser
      ..addOption(
        'config',
        abbr: 'c',
        valueHelp: 'Define a yaml file path.',
        help: 'If not present use the "barreler.yaml" file',
      )
      ..addFlag(
        'set-exit-if-changed',
        defaultsTo: false,
        negatable: false,
        help: 'Fail if there are any changes in the generated barrel files.',
      );
  }

  final FindSettings settings;
  final Logger logger;
  final FileSystem fs;

  @override
  String get name => 'build';

  @override
  String get description => 'Builds the barrel files.';

  @override
  Future<int> run([List<String>? args]) async {
    final argResults = args != null ? argParser.parse(args) : this.argResults;
    final providedConfigPath = argResults?['config'] as String?;

    final exitOnChange = argResults?['set-exit-if-changed'] as bool;

    final handler = BuildHandler(
      logger: logger,
      fs: fs,
      settings: settings,
      providedConfigPath: providedConfigPath,
      exitOnChange: exitOnChange,
    );

    final result = await handler.run();

    return result;
  }
}
