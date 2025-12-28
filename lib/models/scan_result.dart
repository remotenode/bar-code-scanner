import 'package:hive/hive.dart';
import 'barcode_format.dart';
import 'content_type.dart';

part 'scan_result.g.dart';

/// Model representing a scanned barcode result
@HiveType(typeId: 0)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String rawValue;

  @HiveField(1)
  final int formatIndex;

  @HiveField(2)
  final int contentTypeIndex;

  @HiveField(3)
  final DateTime scannedAt;

  @HiveField(4)
  final String? id;

  ScanResult({
    required this.rawValue,
    required this.formatIndex,
    required this.contentTypeIndex,
    required this.scannedAt,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Get the barcode format enum
  BarcodeFormat get format => BarcodeFormat.values[formatIndex];

  /// Get the content type enum
  ContentType get contentType => ContentType.values[contentTypeIndex];

  /// Create a ScanResult from barcode data
  factory ScanResult.fromScan({
    required String rawValue,
    required BarcodeFormat format,
  }) {
    final contentType = ContentTypeParser.parse(rawValue);
    return ScanResult(
      rawValue: rawValue,
      formatIndex: format.index,
      contentTypeIndex: contentType.index,
      scannedAt: DateTime.now(),
    );
  }

  /// Copy with new values
  ScanResult copyWith({
    String? rawValue,
    BarcodeFormat? format,
    ContentType? contentType,
    DateTime? scannedAt,
    String? id,
  }) {
    return ScanResult(
      rawValue: rawValue ?? this.rawValue,
      formatIndex: format?.index ?? formatIndex,
      contentTypeIndex: contentType?.index ?? contentTypeIndex,
      scannedAt: scannedAt ?? this.scannedAt,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ScanResult{rawValue: $rawValue, format: $format, contentType: $contentType, scannedAt: $scannedAt}';
  }
}
