import 'package:flutter/material.dart';
import 'placeholder_logo.dart';

class AssetImageWithFallback extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final BoxFit fit;
  final Color? placeholderColor;
  
  const AssetImageWithFallback({
    super.key,
    required this.assetPath,
    this.width = 40,
    this.height = 40,
    this.fit = BoxFit.contain,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return PlaceholderLogo(
          size: width,
          color: placeholderColor,
        );
      },
    );
  }
} 