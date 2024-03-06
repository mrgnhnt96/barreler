import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:barreler/commands/build_command.dart';
import 'package:barreler/commands/example_command.dart';
import 'package:barreler/src/find_settings.dart';
import 'package:barreler/src/version.dart';
import 'package:file/file.dart';
import 'package:mason_logger/mason_logger.dart';

class BarrelerRunner extends CommandRunner<int> {
  BarrelerRunner({
    required this.logger,
    required FileSystem fs,
  }) : super(
          'barreler',
          'A Dart package to generate barrel files for your directories.',
        ) {
    addCommand(
      BuildCommand(
        fs: fs,
        logger: logger,
        settings: FindSettings(
          fs: fs,
        ),
      ),
    );

    addCommand(
      ExampleCommand(
        fileSystem: fs,
        logger: logger,
      ),
    );

    argParser
      ..addFlag(
        'version',
        defaultsTo: false,
        negatable: false,
        help: 'Print the current version of barreler.',
      )
      ..addFlag(
        'loud',
        defaultsTo: false,
        negatable: false,
        help: 'Print verbose logs',
      )
      ..addFlag(
        'quiet',
        defaultsTo: false,
        negatable: false,
        help: 'Prints no logs',
      );
  }

  final Logger logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      final exitCode = await runCommand(argResults);

      return exitCode;
    } catch (error) {
      logger.err('$error');
      return 1;
    }
  }

  @override
  Future<int> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.wasParsed('version')) {
      logger.info(packageVersion);

      return 0;
    }
    logger.write('\n');

    final result = await super.runCommand(topLevelResults);

    logger.write('\n');
    logger.detail('Exit code: $result');

    return result ?? 0;
  }
}
