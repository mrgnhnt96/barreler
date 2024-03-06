import 'package:barreler/src/settings/default_settings.dart';
import 'package:barreler/src/settings/directory_settings.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings extends Equatable {
  const Settings({
    required this.dirs,
    this.defaultSettings = const DefaultSettings(),
    this.exclude = const [],
    this.include = const [],
    this.lineBreak = '\u{000A}',
    this.lineLength = 80,
  });

  final String lineBreak;
  final int lineLength;
  final List<String> include;
  final List<String> exclude;
  @JsonKey(defaultValue: const [])
  final List<DirectorySettings> dirs;
  @JsonKey(name: 'defaults')
  final DefaultSettings defaultSettings;

  // ignore: strict_raw_type
  factory Settings.fromJson(Map map) => _$SettingsFromJson(map);

  @override
  List<Object?> get props => _$props;
}
