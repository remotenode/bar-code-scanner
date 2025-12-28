import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';

/// Screen for app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _languages = [
    ('en', 'English'),
    ('ru', 'Русский'),
    ('es', 'Español'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance', theme),
              _buildSwitchTile(
                context: context,
                title: l10n.darkMode,
                subtitle: 'Toggle dark/light theme',
                icon: Icons.dark_mode,
                value: settingsService.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  settingsService.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              const Divider(height: 1),

              // Feedback Section
              _buildSectionHeader('Feedback', theme),
              _buildSwitchTile(
                context: context,
                title: l10n.vibration,
                subtitle: 'Vibrate on successful scan',
                icon: Icons.vibration,
                value: settingsService.vibrationEnabled,
                onChanged: settingsService.setVibrationEnabled,
              ),
              _buildSwitchTile(
                context: context,
                title: l10n.sound,
                subtitle: 'Play sound on successful scan',
                icon: Icons.volume_up,
                value: settingsService.soundEnabled,
                onChanged: settingsService.setSoundEnabled,
              ),
              const Divider(height: 1),

              // Language Section
              _buildSectionHeader(l10n.language, theme),
              _buildLanguageSelector(context, settingsService, theme),
              const Divider(height: 1),

              // About Section
              _buildSectionHeader(l10n.about, theme),
              _buildAboutTile(context, l10n, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    SettingsService settingsService,
    ThemeData theme,
  ) {
    return Column(
      children: _languages.map((lang) {
        final (code, name) = lang;
        return RadioListTile<String>(
          title: Text(name),
          value: code,
          groupValue: settingsService.languageCode,
          onChanged: (value) {
            if (value != null) {
              settingsService.setLanguage(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildAboutTile(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.qr_code_scanner,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: const Text('Barcode Scanner'),
      subtitle: Text(l10n.version('1.0.0')),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Barcode Scanner',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.qr_code_scanner,
          size: 48,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      children: [
        const Text(
          'A fast and reliable barcode scanner app with support for '
          'multiple barcode formats including QR codes, Data Matrix, '
          'PDF417, and various 1D formats.',
        ),
      ],
    );
  }
}
