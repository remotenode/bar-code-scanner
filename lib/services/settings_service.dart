import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';

/// Service for managing app settings using Hive local storage
class SettingsService extends ChangeNotifier {
  static const String _boxName = 'app_settings';
  static const String _settingsKey = 'settings';

  Box? _box;
  AppSettings _settings = const AppSettings();

  /// Get current settings
  AppSettings get settings => _settings;

  /// Get current theme mode
  ThemeMode get themeMode => _settings.themeMode;

  /// Get vibration enabled state
  bool get vibrationEnabled => _settings.vibrationEnabled;

  /// Get sound enabled state
  bool get soundEnabled => _settings.soundEnabled;

  /// Get current language code
  String get languageCode => _settings.languageCode;

  /// Get current locale
  Locale get locale => Locale(_settings.languageCode);

  /// Initialize the settings service
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    await _loadSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    final jsonString = _box?.get(_settingsKey) as String?;
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(json);
      } catch (e) {
        _settings = const AppSettings();
      }
    }
    notifyListeners();
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    final jsonString = jsonEncode(_settings.toJson());
    await _box?.put(_settingsKey, jsonString);
    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _saveSettings();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    final newMode = _settings.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Set vibration enabled
  Future<void> setVibrationEnabled(bool enabled) async {
    _settings = _settings.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }

  /// Set sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    _settings = _settings.copyWith(languageCode: languageCode);
    await _saveSettings();
  }

  /// Close the settings box
  Future<void> close() async {
    await _box?.close();
  }
}
