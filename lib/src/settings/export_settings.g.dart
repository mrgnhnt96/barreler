// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_settings.dart';

// **************************************************************************
// AutoequalGenerator
// **************************************************************************

extension _$ExportSettingsAutoequal on ExportSettings {
  List<Object?> get _$props => [
        export,
        show,
        hide,
      ];
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportSettings _$ExportSettingsFromJson(Map json) => $checkedCreate(
      'ExportSettings',
      json,
      ($checkedConvert) {
        final val = ExportSettings(
          export: $checkedConvert('export', (v) => v as String),
          show: $checkedConvert(
            'show',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const [],
            readValue: stringOrList,
          ),
          hide: $checkedConvert(
            'hide',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const [],
            readValue: stringOrList,
          ),
        );
        return val;
      },
    );

Map<String, dynamic> _$ExportSettingsToJson(ExportSettings instance) =>
    <String, dynamic>{
      'export': instance.export,
      'show': instance.show,
      'hide': instance.hide,
    };
