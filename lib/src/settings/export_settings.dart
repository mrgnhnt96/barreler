import 'package:barreler/src/converter_utils/string_or_list.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_settings.g.dart';

@JsonSerializable()
class ExportSettings extends Equatable {
  const ExportSettings({
    required this.export,
    this.show = const [],
    this.hide = const [],
  });

  // ignore: strict_raw_type
  factory ExportSettings.fromJson(Map data) => _$ExportSettingsFromJson(data);

  /// Package name without dart extension
  final String export;

  /// Class to method to show
  @JsonKey(readValue: stringOrList)
  final List<String> show;

  /// Class to method to hide
  @JsonKey(readValue: stringOrList)
  final List<String> hide;

  ExportSettings updatePath(String file) {
    return ExportSettings(
      export: file,
      show: show,
      hide: hide,
    );
  }

  String toCode() {
    return [
      "export '$export' ",
      if (show.isNotEmpty) 'show ${show.join(', ')}',
      if (hide.isNotEmpty) 'hide ${hide.join(', ')}',
      ';',
    ].join('');
  }

  Map<String, dynamic> toJson() => _$ExportSettingsToJson(this);

  @override
  List<Object?> get props => _$props;
}
