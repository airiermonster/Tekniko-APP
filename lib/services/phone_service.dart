import 'package:url_launcher/url_launcher.dart';
import '../utils/phone_utils.dart';

class PhoneService {
  /// Launch a phone call to the given number
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final formattedNumber = PhoneUtils.getDialNumber(phoneNumber);
    final Uri uri = Uri(scheme: 'tel', path: formattedNumber);
    return await launchUrl(uri);
  }
  
  /// Launch SMS app with the given number
  static Future<bool> sendSMS(String phoneNumber) async {
    final formattedNumber = PhoneUtils.formatPhoneNumber(phoneNumber);
    final Uri uri = Uri(scheme: 'sms', path: formattedNumber);
    return await launchUrl(uri);
  }
  
  /// Open WhatsApp chat with the given number
  static Future<bool> openWhatsApp(String phoneNumber) async {
    final formattedNumber = PhoneUtils.getWhatsAppNumber(phoneNumber);
    final url = 'https://wa.me/$formattedNumber';
    final Uri uri = Uri.parse(url);
    
    return await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
} 