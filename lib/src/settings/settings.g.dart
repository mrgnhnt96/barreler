// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// AutoequalGenerator
// **************************************************************************

extension _$SettingsAutoequal on Settings {
  List<Object?> get _$props => [
        lineBreak,
        lineLength,
        include,
        exclude,
        defaultSettings,
        dirs,
      ];
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map json) => $checkedCreate(
      'Settings',
      json,
      ($checkedConvert) {
        final val = Settings(
          dirs: $checkedConvert(
              'dirs',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) => DirectorySettings.fromJson(e as Map))
                      .toList() ??
                  []),
          defaultSettings: $checkedConvert(
              'defaults',
              (v) => v == null
                  ? const DefaultSettings()
                  : DefaultSettings.fromJson(v as Map)),
          exclude: $checkedConvert(
              'exclude',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          include: $checkedConvert(
              'include',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          lineBreak:
              $checkedConvert('line_break', (v) => v as String? ?? '\u{000A}'),
          lineLength: $checkedConvert('line_length', (v) => v as int? ?? 80),
        );
        return val;
      },
      fieldKeyMap: const {
        'defaultSettings': 'defaults',
        'lineBreak': 'line_break',
        'lineLength': 'line_length'
      },
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'line_break': instance.lineBreak,
      'line_length': instance.lineLength,
      'include': instance.include,
      'exclude': instance.exclude,
      'defaults': instance.defaultSettings.toJson(),
      'dirs': instance.dirs.map((e) => e.toJson()).toList(),
    };
