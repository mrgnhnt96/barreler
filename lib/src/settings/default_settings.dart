import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'default_settings.g.dart';

@JsonSerializable()
class DefaultSettings extends Equatable {
  const DefaultSettings({
    this.fileName,
    this.comments,
    this.disclaimer = 'GENERATED CODE - DO NOT MODIFY BY HAND',
  });

  // ignore: strict_raw_type
  factory DefaultSettings.fromJson(Map map) => _$DefaultSettingsFromJson(map);

  final String? fileName;
  final String? comments;
  final String disclaimer;

  @override
  List<Object?> get props => _$props;
}
