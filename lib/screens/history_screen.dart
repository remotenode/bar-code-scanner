import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/history_service.dart';
import 'result_screen.dart';

/// Screen displaying scan history
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final historyService = context.read<HistoryService>();
    final history = historyService.getHistory();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: l10n.clearHistory,
              onPressed: () => _showClearConfirmation(context, l10n),
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState(l10n, theme)
          : _buildHistoryList(history, l10n, theme),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noHistory,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    List<ScanResult> history,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryItem(context, item, l10n, theme);
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    ScanResult item,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Dismissible(
      key: Key(item.id ?? item.rawValue),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      onDismissed: (_) => _deleteItem(context, item, l10n),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () => _openResult(context, item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildContentTypeIcon(item.contentType, theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.rawValue,
                        style: theme.textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _getContentTypeName(item.contentType, l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(item.scannedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentTypeIcon(ContentType contentType, ThemeData theme) {
    IconData iconData;
    switch (contentType) {
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        size: 24,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  String _getContentTypeName(ContentType contentType, AppLocalizations l10n) {
    switch (contentType) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return DateFormat.jm().format(date);
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  void _openResult(BuildContext context, ScanResult item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: item),
      ),
    );
  }

  void _deleteItem(
    BuildContext context,
    ScanResult item,
    AppLocalizations l10n,
  ) async {
    final historyService = context.read<HistoryService>();
    await historyService.deleteScan(item.id!);
    setState(() {});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.itemDeleted),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () async {
              await historyService.addScan(item);
              setState(() {});
            },
          ),
        ),
      );
    }
  }

  void _showClearConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: Text(l10n.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearHistory(context, l10n);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _clearHistory(BuildContext context, AppLocalizations l10n) async {
    final historyService = context.read<HistoryService>();
    await historyService.clearHistory();
    setState(() {});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.historyCleared)),
      );
    }
  }
}
