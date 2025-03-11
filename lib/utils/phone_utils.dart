import 'package:flutter/material.dart';

class PhoneUtils {
  /// Returns network information based on the phone number prefix
  static Map<String, NetworkInfo> identifyNetwork(String phoneNumber) {
    // Remove any non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Default network info if not identified
    NetworkInfo defaultInfo = NetworkInfo(
      name: 'Other',
      color: Colors.grey,
      icon: Icons.phone_android,
    );
    
    // Check if the number is empty or too short
    if (cleanNumber.isEmpty || cleanNumber.length < 3) {
      return {'networkInfo': defaultInfo};
    }
    
    // Check if the number starts with Tanzania country code
    String prefix;
    if (cleanNumber.startsWith('255')) {
      // Extract the prefix after country code: +255 XX
      prefix = cleanNumber.substring(3, 5);
    } else if (cleanNumber.startsWith('0')) {
      // Extract the prefix: 0XX
      prefix = cleanNumber.substring(1, 3);
    } else {
      // For any other format, try to use the first two digits
      prefix = cleanNumber.substring(0, 2);
    }
    
    // Identify network based on prefix
    if (prefix == '71' || prefix == '65') {
      return {
        'networkInfo': NetworkInfo(
          name: 'Airtel',
          color: Colors.red,
          icon: Icons.network_cell,
        )
      };
    } else if (prefix == '75' || prefix == '76') {
      return {
        'networkInfo': NetworkInfo(
          name: 'Vodacom',
          color: Colors.red.shade800,
          icon: Icons.network_cell,
        )
      };
    } else if (prefix == '67' || prefix == '77') {
      return {
        'networkInfo': NetworkInfo(
          name: 'Tigo',
          color: Colors.blue,
          icon: Icons.network_cell,
        )
      };
    } else if (prefix == '78') {
      return {
        'networkInfo': NetworkInfo(
          name: 'Halotel',
          color: Colors.green,
          icon: Icons.network_cell,
        )
      };
    } else if (prefix == '62' || prefix == '74') {
      return {
        'networkInfo': NetworkInfo(
          name: 'TTCL',
          color: Colors.blue.shade900,
          icon: Icons.network_cell,
        )
      };
    } else if (prefix == '68' || prefix == '69') {
      return {
        'networkInfo': NetworkInfo(
          name: 'Zantel',
          color: Colors.orange,
          icon: Icons.network_cell,
        )
      };
    }
    
    return {'networkInfo': defaultInfo};
  }
  
  /// Formats a phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.isEmpty) {
      return '';
    }
    
    // Convert to local format if it has country code
    String formattedNumber;
    if (cleanNumber.startsWith('255') && cleanNumber.length >= 12) {
      // Remove country code and add 0
      formattedNumber = '0${cleanNumber.substring(3)}';
    } else {
      formattedNumber = cleanNumber;
    }
    
    // Ensure it starts with 0
    if (!formattedNumber.startsWith('0') && formattedNumber.length >= 9) {
      formattedNumber = '0$formattedNumber';
    }
    
    // Format with spaces if long enough
    if (formattedNumber.length >= 10) {
      return '${formattedNumber.substring(0, 4)} ${formattedNumber.substring(4, 7)} ${formattedNumber.substring(7)}';
    } else {
      return formattedNumber;
    }
  }
  
  /// Returns a properly formatted phone number for WhatsApp
  static String getWhatsAppNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.isEmpty) {
      return '';
    }
    
    // If it already has country code
    if (cleanNumber.startsWith('255')) {
      return cleanNumber;
    }
    
    // If it starts with 0, replace with country code
    if (cleanNumber.startsWith('0') && cleanNumber.length >= 10) {
      return '255${cleanNumber.substring(1)}';
    }
    
    // If it's just the number without leading 0 or country code
    if (cleanNumber.length >= 9) {
      return '255$cleanNumber';
    }
    
    // Return original if we can't format it
    return cleanNumber;
  }
  
  /// Returns a phone number ready for dialing
  static String getDialNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.isEmpty) {
      return '';
    }
    
    // If it already has country code
    if (cleanNumber.startsWith('255')) {
      return '+$cleanNumber';
    }
    
    // If it starts with 0, replace with country code
    if (cleanNumber.startsWith('0') && cleanNumber.length >= 10) {
      return '+255${cleanNumber.substring(1)}';
    }
    
    // If it's just the number without leading 0 or country code
    if (cleanNumber.length >= 9) {
      return '+255$cleanNumber';
    }
    
    // Return original if we can't format it
    return cleanNumber;
  }
}

class NetworkInfo {
  final String name;
  final Color color;
  final IconData icon;
  
  NetworkInfo({
    required this.name,
    required this.color,
    required this.icon,
  });
} 