import 'package:barreler/src/converter_utils/string_or_list.dart';
import 'package:barreler/src/settings/export_settings.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;

part 'directory_settings.g.dart';

@JsonSerializable()
class DirectorySettings extends Equatable {
  const DirectorySettings({
    required this.dirPath,
    this.fileName,
    this.disclaimer = true,
    this.comments,
    this.exports = const [],
    this.include = const [],
    this.exclude = const [],
  });

  const DirectorySettings._({
    required this.dirPath,
    required this.fileName,
    required this.disclaimer,
    required this.comments,
    required this.exports,
    required this.include,
    required this.exclude,
  });

  /// Folder path to create a index file
  @JsonKey(name: 'path')
  final String dirPath;

  /// File name with extension
  @JsonKey(name: 'name')
  final String? fileName;

  /// Adds the generated code disclaimer
  final bool disclaimer;

  /// Library comments (copyright)
  final String? comments;

  /// List of export packages
  @JsonKey(fromJson: _possibleStringOrMap)
  final List<ExportSettings> exports;

  /// White filters
  @JsonKey(fromJson: _possibleStringOrMap)
  final List<ExportSettings> include;

  /// Black filters
  @JsonKey(readValue: stringOrList)
  final List<String> exclude;

  String resolveFileName(String? defaultFileName) {
    final fileName = this.fileName;
    if (fileName != null) return fileName;

    if (defaultFileName != null) return defaultFileName;

    final dirName = path.basename(dirPath);

    return dirName;
  }

  DirectorySettings changePath(String newDir) {
    return DirectorySettings._(
      dirPath: newDir,
      fileName: fileName,
      disclaimer: disclaimer,
      comments: comments,
      exports: exports,
      include: include,
      exclude: exclude,
    );
  }

  // ignore: strict_raw_type
  factory DirectorySettings.fromJson(Map data) =>
      _$DirectorySettingsFromJson(data);

  @override
  List<Object?> get props => _$props;
}

// ignore: strict_raw_type
List<ExportSettings> _possibleStringOrMap(dynamic json) {
  if (json is String) {
    return [ExportSettings(export: json)];
  }

  if (json is Map) {
    return [ExportSettings.fromJson(json)];
  }

  if (json is! Iterable) {
    return [];
  }

  Iterable<ExportSettings> iterate() sync* {
    for (final item in json) {
      if (item is Map) {
        yield ExportSettings.fromJson(item);
      } else if (item is String) {
        yield ExportSettings(export: item);
      }
    }
  }

  return iterate().toList();
}
