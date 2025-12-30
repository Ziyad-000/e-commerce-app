import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    try {
      // 1. Handle file:/// URIs that might contain base64 data
      String processedUrl = imageUrl;
      if (processedUrl.startsWith('file:///')) {
        processedUrl = processedUrl.substring(8); // Remove 'file:///'
      }

      // 2. Check if it's a valid HTTP/HTTPS URL
      if (processedUrl.startsWith('http://') ||
          processedUrl.startsWith('https://')) {
        return Image.network(
          processedUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        );
      }

      // 3. Otherwise treat as base64
      String base64String = processedUrl;

      // Remove data URI prefix if present (e.g. "data:image/png;base64,")
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      // Clean up newlines or whitespace
      base64String = base64String.replaceAll('\n', '').replaceAll(' ', '');

      Uint8List imageBytes = base64Decode(base64String);
      return Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      color: AppColors.surface2,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.mutedForeground,
          size: 24,
        ),
      ),
    );
  }
}
