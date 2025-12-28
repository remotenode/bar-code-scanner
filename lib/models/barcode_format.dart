/// Enum representing supported barcode formats
enum BarcodeFormat {
  qrCode,
  dataMatrix,
  pdf417,
  aztec,
  ean13,
  ean8,
  upcA,
  upcE,
  code128,
  code39,
  code93,
  itf,
  codabar,
  unknown,
}

/// Extension to get display name for barcode formats
extension BarcodeFormatExtension on BarcodeFormat {
  String get displayName {
    switch (this) {
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.aztec:
        return 'Aztec';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.upcE:
        return 'UPC-E';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.itf:
        return 'ITF';
      case BarcodeFormat.codabar:
        return 'Codabar';
      case BarcodeFormat.unknown:
        return 'Unknown';
    }
  }

  /// Whether this is a 2D barcode format
  bool get is2D {
    switch (this) {
      case BarcodeFormat.qrCode:
      case BarcodeFormat.dataMatrix:
      case BarcodeFormat.pdf417:
      case BarcodeFormat.aztec:
        return true;
      default:
        return false;
    }
  }
}
