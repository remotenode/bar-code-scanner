/// Enum representing the parsed content type of a scanned barcode
enum ContentType {
  url,
  text,
  wifi,
  contact,
  email,
  phone,
  sms,
  calendar,
  geo,
}

/// Extension for content type utilities
extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.url:
        return 'URL';
      case ContentType.text:
        return 'Text';
      case ContentType.wifi:
        return 'WiFi';
      case ContentType.contact:
        return 'Contact';
      case ContentType.email:
        return 'Email';
      case ContentType.phone:
        return 'Phone';
      case ContentType.sms:
        return 'SMS';
      case ContentType.calendar:
        return 'Calendar Event';
      case ContentType.geo:
        return 'Location';
    }
  }

  /// Icon name for this content type
  String get iconName {
    switch (this) {
      case ContentType.url:
        return 'link';
      case ContentType.text:
        return 'text_fields';
      case ContentType.wifi:
        return 'wifi';
      case ContentType.contact:
        return 'person';
      case ContentType.email:
        return 'email';
      case ContentType.phone:
        return 'phone';
      case ContentType.sms:
        return 'sms';
      case ContentType.calendar:
        return 'event';
      case ContentType.geo:
        return 'location_on';
    }
  }
}

/// Utility class to parse content type from raw barcode value
class ContentTypeParser {
  static ContentType parse(String value) {
    final trimmed = value.trim();

    // URL detection
    if (_isUrl(trimmed)) {
      return ContentType.url;
    }

    // WiFi detection (WIFI:T:WPA;S:network;P:password;;)
    if (trimmed.toUpperCase().startsWith('WIFI:')) {
      return ContentType.wifi;
    }

    // vCard contact detection
    if (trimmed.toUpperCase().startsWith('BEGIN:VCARD')) {
      return ContentType.contact;
    }

    // MECARD contact detection
    if (trimmed.toUpperCase().startsWith('MECARD:')) {
      return ContentType.contact;
    }

    // Email detection (mailto: or email pattern)
    if (trimmed.toLowerCase().startsWith('mailto:') || _isEmail(trimmed)) {
      return ContentType.email;
    }

    // Phone detection (tel:)
    if (trimmed.toLowerCase().startsWith('tel:')) {
      return ContentType.phone;
    }

    // SMS detection (sms: or smsto:)
    if (trimmed.toLowerCase().startsWith('sms:') ||
        trimmed.toLowerCase().startsWith('smsto:')) {
      return ContentType.sms;
    }

    // Calendar event detection (vCalendar/iCalendar)
    if (trimmed.toUpperCase().startsWith('BEGIN:VEVENT') ||
        trimmed.toUpperCase().startsWith('BEGIN:VCALENDAR')) {
      return ContentType.calendar;
    }

    // Geo location detection
    if (trimmed.toLowerCase().startsWith('geo:')) {
      return ContentType.geo;
    }

    return ContentType.text;
  }

  static bool _isUrl(String value) {
    final urlPattern = RegExp(
      r'^(https?:\/\/|www\.)[^\s]+',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(value);
  }

  static bool _isEmail(String value) {
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailPattern.hasMatch(value);
  }
}
