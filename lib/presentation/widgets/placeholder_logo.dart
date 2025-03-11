import 'package:flutter/material.dart';

/// A placeholder widget that renders a simple logo
/// Used when the actual logo image is not available
class PlaceholderLogo extends StatelessWidget {
  final double size;
  final Color? color;
  
  const PlaceholderLogo({
    super.key,
    this.size = 48.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: logoColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          'T',
          style: TextStyle(
            color: logoColor,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.6,
          ),
        ),
      ),
    );
  }
} 