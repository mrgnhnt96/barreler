import 'package:args/command_runner.dart';
import 'package:barreler/handlers/build_handler.dart';
import 'package:barreler/src/find_settings.dart';
import 'package:barreler/src/key_press_listener.dart';
import 'package:file/file.dart';
import 'package:mason_logger/mason_logger.dart';

class WatchCommand extends Command<int> {
  WatchCommand({
    required this.settings,
    required this.fs,
    required this.logger,
    required this.keyPressListener,
  }) {
    argParser
      ..addOption(
        'config',
        abbr: 'c',
        valueHelp: 'Define a yaml file path.',
        help: 'If not present use the "barreler.yaml" file',
      );
  }

  final FindSettings settings;
  final Logger logger;
  final FileSystem fs;
  final KeyPressListener keyPressListener;

  @override
  String get name => 'watch';

  @override
  String get description =>
      'Builds the barrel files, then watches for changes.';

  @override
  Future<int> run([List<String>? args]) async {
    final argResults = args != null ? argParser.parse(args) : this.argResults;
    final providedConfigPath = argResults?['config'] as String?;

    final handler = BuildHandler(
      logger: logger,
      fs: fs,
      settings: settings,
      providedConfigPath: providedConfigPath,
      exitOnChange: false,
      keyPressListener: keyPressListener,
    );

    await handler.run();

    while (true) {
      final (exit: exit) = await handler.waitForChange();

      if (exit) {
        break;
      }

      await handler.run();
    }

    return 0;
  }
}
