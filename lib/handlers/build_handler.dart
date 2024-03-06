import 'package:barreler/src/barrel.dart';
import 'package:barreler/src/extensions/string_extension.dart';
import 'package:barreler/src/find_settings.dart';
import 'package:barreler/src/settings/settings.dart';
import 'package:checked_yaml/checked_yaml.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:mason_logger/mason_logger.dart';

class BuildHandler {
  const BuildHandler({
    required this.logger,
    required this.fs,
    required this.settings,
    required this.providedConfigPath,
    required this.exitOnChange,
  });

  final Logger logger;
  final FileSystem fs;
  final FindSettings settings;
  final String? providedConfigPath;
  final bool exitOnChange;

  Future<List<Barrel>> getBarrels(Settings settings) async {
    final barrels = <Barrel>[];

    for (final dir in settings.dirs) {
      final matches =
          await Glob(dir.dirPath).listFileSystemSync(fs, followLinks: false);

      if (matches.length == 1) {
        barrels.add(Barrel.from(settings, dir, fs));
        continue;
      }

      for (final entity in matches) {
        if (entity is! Directory) {
          continue;
        }
        final updated =
            dir.changePath(entity.path.relativeTo(fs.currentDirectory.path));

        barrels.add(Barrel.from(settings, updated, fs));
      }
    }

    // longest path first, incase nested directories barrel files are to be exported later
    barrels.sort((a, b) => b.dirPath.length.compareTo(a.dirPath.length));

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
      final name = barrel.dirSettings.fileName ?? barrel.name;
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
