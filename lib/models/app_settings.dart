import 'package:flutter/material.dart';

/// Model representing app settings
class AppSettings {
  final ThemeMode themeMode;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final String languageCode;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.vibrationEnabled = true,
    this.soundEnabled = true,
    this.languageCode = 'en',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? vibrationEnabled,
    bool? soundEnabled,
    String? languageCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'vibrationEnabled': vibrationEnabled,
      'soundEnabled': soundEnabled,
      'languageCode': languageCode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          vibrationEnabled == other.vibrationEnabled &&
          soundEnabled == other.soundEnabled &&
          languageCode == other.languageCode;

  @override
  int get hashCode =>
      themeMode.hashCode ^
      vibrationEnabled.hashCode ^
      soundEnabled.hashCode ^
      languageCode.hashCode;
}
