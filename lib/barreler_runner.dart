import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:barreler/commands/build_command.dart';
import 'package:barreler/commands/example_command.dart';
import 'package:barreler/commands/update_command.dart';
import 'package:barreler/commands/watch_command.dart';
import 'package:barreler/src/find_settings.dart';
import 'package:barreler/src/key_press_listener.dart';
import 'package:barreler/src/version.dart';
import 'package:file/file.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

class BarrelerRunner extends CommandRunner<int> {
  BarrelerRunner({
    required this.logger,
    required FileSystem fs,
    required KeyPressListener keyPressListener,
    required PubUpdater pubUpdater,
    required FindSettings findSettings,
  }) : super(
          'barreler',
          'A Dart package to generate barrel files for your directories.',
        ) {
    addCommand(
      BuildCommand(
        fs: fs,
        logger: logger,
        settings: findSettings,
      ),
    );
    addCommand(
      WatchCommand(
        fs: fs,
        logger: logger,
        settings: findSettings,
        keyPressListener: keyPressListener,
      ),
    );
    addCommand(
      updateCommand = UpdateCommand(
        logger: logger,
        pubUpdater: pubUpdater,
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
      )
      ..addFlag(
        'version-check',
        defaultsTo: true,
        help: 'Do not check for new versions of sip_cli',
      );
  }

  final Logger logger;
  late final UpdateCommand updateCommand;

  @override
  Future<int> run(Iterable<String> args) async {
    int exitCode;
    ArgResults? argResults;
    try {
      argResults = parse(args);

      exitCode = await runCommand(argResults);
    } catch (error) {
      logger.err('$error');
      exitCode = 1;
    } finally {
      if (argResults?['version-check'] case true) {
        logger.detail('Checking for updates');
        await checkForUpdate();
      } else {
        logger.detail('Skipping version check');
      }
    }

    return exitCode;
  }

  Future<void> checkForUpdate() async {
    final (needsUpdate, latestVersion) = await updateCommand.needsUpdate();

    if (needsUpdate) {
      const changelog =
          'https://github.com/mrgnhnt96/barreler/blob/main/CHANGELOG.md';

      final package = cyan.wrap('barreler');
      final currentVersion = red.wrap(packageVersion);
      final updateToVersion = green.wrap(latestVersion);
      final updateCommand = yellow.wrap('barreler update');
      final changelogLink = darkGray.wrap(changelog);

      final message = '''
  ┌─────────────────────────────────────────────────────────────────────────┐ 
  │ New update for $package is available!                                   │ 
  │ You are using $currentVersion, the latest is $updateToVersion.                               │ 
  │ Run `$updateCommand` to update to the latest version.                  │ 
  │ Changelog: $changelogLink │ 
  └─────────────────────────────────────────────────────────────────────────┘ 
''';

      logger.write(message);
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
