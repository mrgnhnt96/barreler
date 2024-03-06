// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directory_settings.dart';

// **************************************************************************
// AutoequalGenerator
// **************************************************************************

extension _$DirectorySettingsAutoequal on DirectorySettings {
  List<Object?> get _$props => [
        dirPath,
        fileName,
        disclaimer,
        comments,
        exports,
        include,
        exclude,
      ];
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectorySettings _$DirectorySettingsFromJson(Map json) => $checkedCreate(
      'DirectorySettings',
      json,
      ($checkedConvert) {
        final val = DirectorySettings(
          dirPath: $checkedConvert('path', (v) => v as String),
          fileName: $checkedConvert('name', (v) => v as String?),
          disclaimer: $checkedConvert('disclaimer', (v) => v as bool? ?? true),
          comments: $checkedConvert('comments', (v) => v as String?),
          exports: $checkedConvert(
              'exports', (v) => v == null ? const [] : _possibleStringOrMap(v)),
          include: $checkedConvert(
              'include', (v) => v == null ? const [] : _possibleStringOrMap(v)),
          exclude: $checkedConvert(
            'exclude',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const [],
            readValue: stringOrList,
          ),
        );
        return val;
      },
      fieldKeyMap: const {'dirPath': 'path', 'fileName': 'name'},
    );

Map<String, dynamic> _$DirectorySettingsToJson(DirectorySettings instance) =>
    <String, dynamic>{
      'path': instance.dirPath,
      'name': instance.fileName,
      'disclaimer': instance.disclaimer,
      'comments': instance.comments,
      'exports': instance.exports.map((e) => e.toJson()).toList(),
      'include': instance.include.map((e) => e.toJson()).toList(),
      'exclude': instance.exclude,
    };
