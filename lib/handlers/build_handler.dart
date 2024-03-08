import 'dart:async';

import 'package:barreler/src/barrel.dart';
import 'package:barreler/src/extensions/string_extension.dart';
import 'package:barreler/src/find_settings.dart';
import 'package:barreler/src/key_press_listener.dart';
import 'package:barreler/src/settings/settings.dart';
import 'package:checked_yaml/checked_yaml.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart';

class BuildHandler {
  const BuildHandler({
    required this.logger,
    required this.fs,
    required this.settings,
    required this.providedConfigPath,
    required this.exitOnChange,
    required this.keyPressListener,
  });

  final Logger logger;
  final FileSystem fs;
  final FindSettings settings;
  final String? providedConfigPath;
  final bool exitOnChange;
  final KeyPressListener? keyPressListener;

  Future<List<Barrel>> getBarrels(Settings settings) async {
    final barrels = <Barrel>[];

    for (final dir in settings.dirs) {
      final matches =
          await Glob(dir.dirPath).listFileSystemSync(fs, followLinks: false);

      if (matches.length == 1) {
        barrels.add(Barrel.from(settings, dir, fs, logger));
        continue;
      }

      for (final entity in matches) {
        if (entity is! Directory) {
          continue;
        }
        final updated =
            dir.changePath(entity.path.relativeTo(fs.currentDirectory.path));

        barrels.add(Barrel.from(settings, updated, fs, logger));
      }
    }

    // longest path first, incase nested directories barrel files are to be exported later
    barrels.sort((a, b) =>
        b.dirSettings.dirPath.length.compareTo(a.dirSettings.dirPath.length));

    return barrels;
  }

  Future<Settings> getSettings(String path) async {
    final content = await fs.file(path).readAsString();

    final settings = checkedYamlDecode(
      content,
      (e) => Settings.fromJson(e ?? {}),
      sourceUrl: Uri.parse(path),
    );

    return settings;
  }

  Future<(String?, int?)> getConfigPath() async {
    final configPath = await this.settings.path(providedConfigPath);

    if (configPath == null) {
      logger.err('No config file found.');
      return (null, 1);
    }

    logger.detail('Using settings file: $configPath');

    if (fs.currentDirectory.path != fs.file(configPath).parent.path) {
      final newDir = fs.file(configPath).parent;
      logger.detail('Changing directory to ${newDir.path}');
      fs.currentDirectory = newDir;
    }

    return (configPath, null);
  }

  Future<bool> createBarrelFiles(List<Barrel> barrels) async {
    String? failure;

    for (final barrel in barrels) {
      final path = barrel.dirSettings.dirPath;
      final name = basename(barrel.barrelFile);
      final barrelString = '${blue.wrap(name)} ${darkGray.wrap('— in $path')}';
      final done = logger.progress(
        'Creating $barrelString',
      );

      try {
        final result = await barrel.create(allowChange: !exitOnChange);
        final contentMatches = result?.contentMatches == true;

        if (exitOnChange && !contentMatches) {
          final error = 'Changes detected in $barrelString';
          done.fail(barrelString);
          failure ??= '';
          failure += '\n$error';
        } else if (exitOnChange) {
          done.complete('No changes to $barrelString');
        } else {
          done.complete();
        }
      } catch (e) {
        failure ??= '';
        failure += '\n$barrelString';
        done.fail(barrelString);
        logger.err('Error building ${barrel.dirSettings.dirPath} $e');
      }
    }

    if (failure != null) {
      logger.write('\n');
      logger.err('${red.wrap('\nErrors:')}$failure');

      return false;
    }

    return true;
  }

  Future<({bool exit})> waitForChange() async {
    final (configPath, exitCode) = await getConfigPath();
    if (exitCode != null) {
      return (exit: true);
    } else if (configPath == null) {
      return (exit: true);
    }

    final settings = await getSettings(configPath);

    final barrels = await getBarrels(settings);

    final directories = barrels.map((e) => e.dirSettings.dirPath).toSet();

    final events = {
      FileSystemEvent.delete,
      FileSystemEvent.create,
      FileSystemEvent.move
    };

    String eventType(int event) {
      switch (event) {
        case FileSystemEvent.create:
          return 'create';
        case FileSystemEvent.delete:
          return 'delete';
        case FileSystemEvent.move:
          return 'move';
        case FileSystemEvent.modify:
          return 'modify';
        case FileSystemEvent.all:
          return 'all';
        default:
          return 'unknown';
      }
    }

    final barrelPaths = barrels.map((e) => e.barrelFile).toSet();

    final fileModifications = directories.map((dir) {
      StreamSubscription<void>? subscription;
      final controller = StreamController<void>.broadcast(
        onCancel: () async {
          await subscription?.cancel();
        },
      );

      final watcher =
          fs.directory(dir).watch(recursive: true, events: FileSystemEvent.all);

      subscription = watcher.listen((event) {
        logger.detail('\n');
        logger.detail('File event: ${eventType(event.type)}');
        logger.detail('File changed: ${event.path}');
        if (barrelPaths.contains(event.path)) {
          return;
        }

        if (!events.contains(event.type)) {
          return;
        }

        controller.add(null);
      });

      return controller.stream;
    }).toList();

    void writeWaitingMessage() {
      final waitingMessage = '''
${yellow.wrap('Waiting for changes...')}
${darkGray.wrap('Press `Ctrl+C` or `q` to exit')}
${darkGray.wrap('Press `r` to rebuild')}
''';

      logger.write(waitingMessage);
    }

    final fileChangeCompleter = Completer<({bool exit})?>();

    final input = keyPressListener?.listenToKeystrokes(
      onExit: () {
        fileChangeCompleter.complete((exit: true));
      },
      onRebuild: () {
        fileChangeCompleter.complete();
      },
      onEscape: writeWaitingMessage,
    );

    StreamSubscription<void>? inputSubscription;
    inputSubscription = input?.listen((_) {});

    final fileChangeListener = StreamGroup(fileModifications)
        .merge()
        .listen((_) => fileChangeCompleter.complete());

    writeWaitingMessage();

    final result = await fileChangeCompleter.future;
    await fileChangeListener.cancel();
    inputSubscription?.cancel();

    final shouldExit = result?.exit ?? false;

    if (shouldExit) {
      return (exit: true);
    }

    final changeMessage = '''
${yellow.wrap('Changes detected')}
''';

    logger.write(changeMessage);

    return (exit: false);
  }

  Future<int> run() async {
    final (configPath, exitCode) = await getConfigPath();
    if (exitCode != null) {
      return exitCode;
    } else if (configPath == null) {
      return 1;
    }

    final settings = await getSettings(configPath);

    final barrels = await getBarrels(settings);

    final success = await createBarrelFiles(barrels);

    if (!success) {
      return 1;
    }

    logger.write('\n');
    logger.success('Barrel files created');

    return 0;
  }
}

class StreamGroup<T> {
  StreamGroup(this.streams);

  final List<Stream<T>> streams;

  Stream<void> merge() {
    final controller = StreamController<void>.broadcast();

    final subscriptions = <StreamSubscription<void>>[];

    for (final stream in streams) {
      final subscription = stream.listen((event) {
        controller.add(event);
      });

      subscriptions.add(subscription);
    }

    controller.onCancel = () {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    };

    return controller.stream;
  }
}
