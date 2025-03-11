import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'placeholder_logo.dart';

/// A widget that attempts to load an image in multiple formats,
/// falling back to alternatives or a placeholder if initial loading fails
class MultiFormatImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;
  final Color? placeholderColor;
  
  const MultiFormatImage({
    super.key,
    required this.imagePath,
    this.width = 40,
    this.height = 40,
    this.fit = BoxFit.contain,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    // For simplicity, just check if the path ends with .svg
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => _buildPlaceholder(),
      );
    }
    
    // For other image formats, try regular asset image with fallback
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // First try an alternate format if the original fails
        final alternateFormat = _getAlternateFormat(imagePath);
        if (alternateFormat != null) {
          return Image.asset(
            alternateFormat,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
        
        // If no alternate or alternate fails, use placeholder
        return _buildPlaceholder();
      },
    );
  }
  
  Widget _buildPlaceholder() {
    return PlaceholderLogo(
      size: width,
      color: placeholderColor,
    );
  }
  
  String? _getAlternateFormat(String originalPath) {
    if (originalPath.toLowerCase().endsWith('.png')) {
      // Try jpg if png fails
      return originalPath.substring(0, originalPath.length - 4) + '.jpg';
    } else if (originalPath.toLowerCase().endsWith('.jpg') || 
              originalPath.toLowerCase().endsWith('.jpeg')) {
      // Try png if jpg fails
      return originalPath.substring(0, originalPath.length - 4) + '.png';
    }
    
    // If we can't determine an alternate format, return null
    return null;
  }
} 