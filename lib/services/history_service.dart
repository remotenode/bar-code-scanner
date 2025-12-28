import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_result.dart';

/// Service for managing scan history using Hive local storage
class HistoryService {
  static const String _boxName = 'scan_history';
  static const int _maxHistoryItems = 100;

  Box<ScanResult>? _box;

  /// Initialize the history service
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScanResultAdapter());
    _box = await Hive.openBox<ScanResult>(_boxName);
  }

  /// Get the history box
  Box<ScanResult> get box {
    if (_box == null) {
      throw StateError('HistoryService not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all history items sorted by date (newest first)
  List<ScanResult> getHistory() {
    final items = box.values.toList();
    items.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return items;
  }

  /// Add a scan result to history
  Future<void> addScan(ScanResult result) async {
    // Check for duplicates (same raw value within last 2 seconds)
    final recentItems = getHistory();
    final isDuplicate = recentItems.any((item) =>
        item.rawValue == result.rawValue &&
        DateTime.now().difference(item.scannedAt).inSeconds < 2);

    if (isDuplicate) {
      return;
    }

    await box.put(result.id, result);

    // Trim history if it exceeds max items
    await _trimHistory();
  }

  /// Delete a scan result from history
  Future<void> deleteScan(String id) async {
    await box.delete(id);
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await box.clear();
  }

  /// Trim history to max items
  Future<void> _trimHistory() async {
    if (box.length > _maxHistoryItems) {
      final items = getHistory();
      final itemsToDelete = items.skip(_maxHistoryItems).toList();
      for (final item in itemsToDelete) {
        await box.delete(item.id);
      }
    }
  }

  /// Check if history is empty
  bool get isEmpty => box.isEmpty;

  /// Get history count
  int get count => box.length;

  /// Close the history box
  Future<void> close() async {
    await box.close();
  }
}
