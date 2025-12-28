import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scan_result.dart';
import '../models/content_type.dart';

/// Service for handling actions on scan results (copy, share, open, etc.)
class ActionService {
  /// Copy raw value to clipboard
  Future<void> copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }

  /// Share the scan result
  Future<void> share(ScanResult result) async {
    await Share.share(result.rawValue);
  }

  /// Open URL in browser
  Future<bool> openUrl(String url) async {
    String urlToOpen = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      urlToOpen = 'https://$url';
    }

    final uri = Uri.parse(urlToOpen);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// Open email client
  Future<bool> openEmail(String emailData) async {
    String email = emailData;
    if (email.toLowerCase().startsWith('mailto:')) {
      email = email.substring(7);
    }

    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  /// Open phone dialer
  Future<bool> openPhone(String phoneData) async {
    String phone = phoneData;
    if (phone.toLowerCase().startsWith('tel:')) {
      phone = phone.substring(4);
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  /// Open SMS app
  Future<bool> openSms(String smsData) async {
    String sms = smsData;
    if (sms.toLowerCase().startsWith('sms:')) {
      sms = sms.substring(4);
    } else if (sms.toLowerCase().startsWith('smsto:')) {
      sms = sms.substring(6);
    }

    final uri = Uri(scheme: 'sms', path: sms);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  /// Open map for geo location
  Future<bool> openGeo(String geoData) async {
    String geo = geoData;
    if (geo.toLowerCase().startsWith('geo:')) {
      geo = geo.substring(4);
    }

    // Try to open with Google Maps
    final googleMapsUri = Uri.parse('https://www.google.com/maps?q=$geo');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// Perform the default action based on content type
  Future<bool> performDefaultAction(ScanResult result) async {
    switch (result.contentType) {
      case ContentType.url:
        return await openUrl(result.rawValue);
      case ContentType.email:
        return await openEmail(result.rawValue);
      case ContentType.phone:
        return await openPhone(result.rawValue);
      case ContentType.sms:
        return await openSms(result.rawValue);
      case ContentType.geo:
        return await openGeo(result.rawValue);
      case ContentType.wifi:
        // Copy WiFi details to clipboard
        await copyToClipboard(result.rawValue);
        return true;
      case ContentType.contact:
        // Copy contact details to clipboard
        await copyToClipboard(result.rawValue);
        return true;
      case ContentType.calendar:
        // Copy calendar event to clipboard
        await copyToClipboard(result.rawValue);
        return true;
      case ContentType.text:
        await copyToClipboard(result.rawValue);
        return true;
    }
  }

  /// Parse WiFi data from QR code
  Map<String, String>? parseWifiData(String rawValue) {
    if (!rawValue.toUpperCase().startsWith('WIFI:')) {
      return null;
    }

    final data = <String, String>{};
    final content = rawValue.substring(5);

    // Parse WIFI:T:WPA;S:ssid;P:password;;
    final regex = RegExp(r'([TPS]):([^;]*);?');
    final matches = regex.allMatches(content);

    for (final match in matches) {
      final key = match.group(1);
      final value = match.group(2);
      if (key != null && value != null) {
        switch (key) {
          case 'T':
            data['type'] = value;
            break;
          case 'S':
            data['ssid'] = value;
            break;
          case 'P':
            data['password'] = value;
            break;
        }
      }
    }

    return data.isNotEmpty ? data : null;
  }
}
