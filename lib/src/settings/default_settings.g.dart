// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_settings.dart';

// **************************************************************************
// AutoequalGenerator
// **************************************************************************

extension _$DefaultSettingsAutoequal on DefaultSettings {
  List<Object?> get _$props => [
        fileName,
        comments,
        disclaimer,
      ];
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DefaultSettings _$DefaultSettingsFromJson(Map json) => $checkedCreate(
      'DefaultSettings',
      json,
      ($checkedConvert) {
        final val = DefaultSettings(
          fileName: $checkedConvert('file_name', (v) => v as String?),
          comments: $checkedConvert('comments', (v) => v as String?),
          disclaimer: $checkedConvert('disclaimer',
              (v) => v as String? ?? 'GENERATED CODE - DO NOT MODIFY BY HAND'),
        );
        return val;
      },
      fieldKeyMap: const {'fileName': 'file_name'},
    );

Map<String, dynamic> _$DefaultSettingsToJson(DefaultSettings instance) =>
    <String, dynamic>{
      'file_name': instance.fileName,
      'comments': instance.comments,
      'disclaimer': instance.disclaimer,
    };
