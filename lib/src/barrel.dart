import 'package:autoequal/autoequal.dart';
import 'package:barreler/src/extensions/string_extension.dart';
import 'package:barreler/src/settings/directory_settings.dart';
import 'package:barreler/src/settings/settings.dart';
import 'package:dart_style/dart_style.dart';
import 'package:equatable/equatable.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:mason_logger/mason_logger.dart';

part 'barrel.g.dart';

class Barrel extends Equatable {
  Barrel({
    required this.baseSettings,
    required this.dirSettings,
    required this.fs,
    required this.logger,
  });

  final Settings baseSettings;
  final DirectorySettings dirSettings;
  @ignore
  final FileSystem fs;
  @ignore
  final Logger logger;

  factory Barrel.from(
    Settings baseSettings,
    DirectorySettings dirSettings,
    FileSystem fs,
    Logger logger,
  ) {
    return Barrel(
      baseSettings: baseSettings,
      dirSettings: dirSettings,
      fs: fs,
      logger: logger,
    );
  }

  String get barrelFile =>
      dirSettings.barrelFile(baseSettings.defaultSettings.fileName);

  /// Find dart files without settings file
  Iterable<String> findFiles() sync* {
    final files = fs
        .directory(dirSettings.dirPath)
        .listSync(recursive: true, followLinks: false);

    for (final file in files) {
      if (file is! File) continue;

      final filePath = file.path;
      if (!filePath.endsWith('.dart')) continue;
      if (filePath == barrelFile) continue;

      yield filePath;
    }
  }

  /// Filter [files]  and [dirSettings] filters
  Iterable<String> filterFiles(Iterable<String> files) sync* {
    final include = [
      ...baseSettings.include,
      ...dirSettings.include.map((e) => e.export)
    ];
    final exclude = [...baseSettings.exclude, ...dirSettings.exclude];

    logger.detail('Include: $include');
    logger.detail('Exclude: $exclude');

    for (final file in files) {
      final isIncluded = include.isEmpty ||
          include.any((f) {
            if (Glob(f).matches(file)) {
              return true;
            }

            if (file.endsWith(f)) {
              return true;
            }
            if (f.contains(path.separator) && !f.startsWith('*')) {
              if (Glob(path.join(dirSettings.dirPath, f)).matches(file)) {
                return true;
              }
            }

            return false;
          });
      if (!isIncluded) {
        continue;
      }

      final isExcluded =
          exclude.any((f) => Glob(f).matches(file) || file.endsWith(f));
      if (isExcluded) {
        continue;
      }

      yield file;
    }
  }

  /// Convert dart [files] in settings content lines
  Iterable<String> exports(Iterable<String> files) sync* {
    final mappedExports = {
      for (final export in dirSettings.include) export.export: export,
    };

    for (final file in files) {
      final filePath = file.relativeTo(dirSettings.dirPath);

      final exportSettings = mappedExports[filePath] ?? mappedExports[file];

      if (exportSettings != null) {
        yield exportSettings.updatePath(filePath).toCode();
        continue;
      }

      yield "export '$filePath';";
    }
  }

  /// Generate a settings file content
  Iterable<String>? content({
    required Iterable<String> disclaimer,
    required Iterable<String> comments,
    required Iterable<String> externalExports,
    required Iterable<String> internalExports,
  }) {
    if ([...externalExports, ...internalExports].isEmpty) return null;

    return [
      if (dirSettings.disclaimer && disclaimer.isNotEmpty) ...[
        for (final line in [
          ...disclaimer,
          if (comments.isNotEmpty) '',
        ])
          '// $line',
      ],
      if (comments.isNotEmpty) ...[
        for (final line in comments) '// $line',
      ],
      '',
      if (externalExports.isNotEmpty) ...[
        ...externalExports,
        '',
      ],
      ...internalExports,
      '',
    ];
  }

  /// Create a settings file content
  Future<({bool contentMatches})?> create({required bool allowChange}) async {
    final formatter = DartFormatter(
      lineEnding: baseSettings.lineBreak,
      pageWidth: baseSettings.lineLength,
    );

    final disclaimer = baseSettings.defaultSettings.disclaimer.removeWrapping();
    final comments =
        (dirSettings.comments ?? baseSettings.defaultSettings.comments ?? '')
            .removeWrapping();

    final externalExports = dirSettings.exports.map((e) => e.toCode()).toList()
      ..sort();

    final internalFiles = findFiles();
    logger.detail('Found ${internalFiles.length} files');

    final internalFilteredFiles = filterFiles(internalFiles);

    logger.detail(
        'Exporting ${internalFilteredFiles.length} files (after filtering)');

    final internalExports = exports(internalFilteredFiles).toList()..sort();

    final generated = this.content(
      disclaimer: disclaimer,
      comments: comments,
      externalExports: externalExports,
      internalExports: internalExports,
    );

    final file = fs.file(barrelFile);

    if (generated == null) {
      return null;
    }

    final barrelContent = formatter.format(
      generated.join(baseSettings.lineBreak),
    );

    if (!allowChange) {
      final content = await file.exists() ? await file.readAsString() : null;

      return (contentMatches: content == barrelContent);
    }

    await file.writeAsString(barrelContent);

    return null;
  }

  @override
  List<Object?> get props => _$props;
}
