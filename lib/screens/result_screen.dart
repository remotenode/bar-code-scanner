import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/action_service.dart';

/// Screen displaying scan result with action buttons
class ResultScreen extends StatelessWidget {
  final ScanResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final actionService = context.read<ActionService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Format and content type card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildContentTypeIcon(theme),
                    const SizedBox(height: 16),
                    Text(
                      _getContentTypeName(l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.format.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Raw value card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.text_snippet,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Raw Value',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      result.rawValue,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // WiFi details (if applicable)
            if (result.contentType == ContentType.wifi)
              _buildWifiDetails(theme, actionService),

            // Scanned time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.scannedAt(
                        DateFormat.yMMMd().add_jm().format(result.scannedAt),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context, l10n, theme, actionService),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTypeIcon(ThemeData theme) {
    IconData iconData;
    switch (result.contentType) {
      case ContentType.url:
        iconData = Icons.link;
        break;
      case ContentType.wifi:
        iconData = Icons.wifi;
        break;
      case ContentType.contact:
        iconData = Icons.person;
        break;
      case ContentType.email:
        iconData = Icons.email;
        break;
      case ContentType.phone:
        iconData = Icons.phone;
        break;
      case ContentType.sms:
        iconData = Icons.sms;
        break;
      case ContentType.calendar:
        iconData = Icons.event;
        break;
      case ContentType.geo:
        iconData = Icons.location_on;
        break;
      case ContentType.text:
      default:
        iconData = Icons.text_fields;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 48,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  String _getContentTypeName(AppLocalizations l10n) {
    switch (result.contentType) {
      case ContentType.url:
        return l10n.contentTypeUrl;
      case ContentType.wifi:
        return l10n.contentTypeWifi;
      case ContentType.contact:
        return l10n.contentTypeContact;
      case ContentType.email:
        return l10n.contentTypeEmail;
      case ContentType.phone:
        return l10n.contentTypePhone;
      case ContentType.sms:
        return l10n.contentTypeSms;
      case ContentType.calendar:
        return l10n.contentTypeCalendar;
      case ContentType.geo:
        return l10n.contentTypeGeo;
      case ContentType.text:
        return l10n.contentTypeText;
    }
  }

  Widget _buildWifiDetails(ThemeData theme, ActionService actionService) {
    final wifiData = actionService.parseWifiData(result.rawValue);
    if (wifiData == null) return const SizedBox.shrink();

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'WiFi Details',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (wifiData['ssid'] != null) ...[
                  _buildDetailRow('Network', wifiData['ssid']!, theme),
                  const SizedBox(height: 8),
                ],
                if (wifiData['type'] != null) ...[
                  _buildDetailRow('Security', wifiData['type']!, theme),
                  const SizedBox(height: 8),
                ],
                if (wifiData['password'] != null)
                  _buildDetailRow('Password', wifiData['password']!, theme),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ActionService actionService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary action button
        if (_hasPrimaryAction())
          FilledButton.icon(
            icon: Icon(_getPrimaryActionIcon()),
            label: Text(_getPrimaryActionLabel(l10n)),
            onPressed: () => _handlePrimaryAction(context, actionService, l10n),
          ),
        if (_hasPrimaryAction()) const SizedBox(height: 12),

        // Copy button
        OutlinedButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(l10n.copy),
          onPressed: () => _handleCopy(context, actionService, l10n),
        ),
        const SizedBox(height: 12),

        // Share button
        OutlinedButton.icon(
          icon: const Icon(Icons.share),
          label: Text(l10n.share),
          onPressed: () => actionService.share(result),
        ),
      ],
    );
  }

  bool _hasPrimaryAction() {
    switch (result.contentType) {
      case ContentType.url:
      case ContentType.email:
      case ContentType.phone:
      case ContentType.sms:
      case ContentType.geo:
        return true;
      default:
        return false;
    }
  }

  IconData _getPrimaryActionIcon() {
    switch (result.contentType) {
      case ContentType.url:
        return Icons.open_in_browser;
      case ContentType.email:
        return Icons.email;
      case ContentType.phone:
        return Icons.call;
      case ContentType.sms:
        return Icons.message;
      case ContentType.geo:
        return Icons.map;
      default:
        return Icons.open_in_new;
    }
  }

  String _getPrimaryActionLabel(AppLocalizations l10n) {
    switch (result.contentType) {
      case ContentType.url:
        return l10n.open;
      case ContentType.email:
        return l10n.open;
      case ContentType.phone:
        return l10n.open;
      case ContentType.sms:
        return l10n.open;
      case ContentType.geo:
        return l10n.open;
      default:
        return l10n.open;
    }
  }

  void _handlePrimaryAction(
    BuildContext context,
    ActionService actionService,
    AppLocalizations l10n,
  ) async {
    final success = await actionService.performDefaultAction(result);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this content')),
      );
    }
  }

  void _handleCopy(
    BuildContext context,
    ActionService actionService,
    AppLocalizations l10n,
  ) async {
    await actionService.copyToClipboard(result.rawValue);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.copied)),
      );
    }
  }
}
