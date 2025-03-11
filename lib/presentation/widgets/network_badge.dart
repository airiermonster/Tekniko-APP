import 'package:flutter/material.dart';
import '../../utils/phone_utils.dart';

class NetworkBadge extends StatelessWidget {
  final String phoneNumber;
  final bool showName;
  
  const NetworkBadge({
    super.key,
    required this.phoneNumber,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    final networkInfo = PhoneUtils.identifyNetwork(phoneNumber)['networkInfo'] as NetworkInfo;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: networkInfo.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: networkInfo.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            networkInfo.icon,
            size: 14,
            color: networkInfo.color,
          ),
          if (showName) ...[
            const SizedBox(width: 4),
            Text(
              networkInfo.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: networkInfo.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 