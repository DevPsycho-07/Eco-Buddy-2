// ignore_for_file: dangling_library_doc_comments

/// Image optimization and compression utilities
/// 
/// Provides tools for compressing and optimizing images before upload
/// and efficient loading of images with caching.
/// 
/// Example:
/// ```dart
/// // Compress image before upload
/// final compressedImage = await ImageOptimizer.compressImage(imageFile);
/// 
/// // Display optimized cached image
/// OptimizedCachedImage(
///   imageUrl: userProfile.avatarUrl,
///   width: 100,
///   height: 100,
/// )
/// ```
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_logger.dart';

/// Image compression and optimization utilities
class ImageOptimizer {
  /// Compress image file for upload
  /// 
  /// Reduces file size while maintaining acceptable quality.
  /// Returns compressed image bytes.
  static Future<Uint8List?> compressImage(
    File imageFile, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      AppLogger.info('Compressing image: ${imageFile.path}');
      
      final result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      if (result != null) {
        final originalSize = await imageFile.length();
        final compressedSize = result.length;
        final reduction = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);
        
        AppLogger.info(
          'Image compressed: ${originalSize}B → ${compressedSize}B ($reduction% reduction)',
        );
      }

      return result;
    } catch (e) {
      AppLogger.error('Failed to compress image', error: e);
      return null;
    }
  }

  /// Compress image for profile picture (smaller size)
  static Future<Uint8List?> compressProfilePicture(File imageFile) async {
    return compressImage(
      imageFile,
      quality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
  }

  /// Save compressed image to temp directory
  static Future<File?> saveCompressedImage(
    Uint8List imageData,
    String fileName,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageData);
      return file;
    } catch (e) {
      AppLogger.error('Failed to save compressed image', error: e);
      return null;
    }
  }

  /// Get image dimensions
  static Future<Size?> getImageSize(File imageFile) async {
    try {
      final image = await decodeImageFromList(await imageFile.readAsBytes());
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      AppLogger.error('Failed to get image size', error: e);
      return null;
    }
  }
}

/// Optimized cached network image widget
/// 
/// Displays images with automatic caching, compression, and loading states
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade500,
              size: 40,
            ),
          ),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// Circular avatar with cached network image
class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final Color? backgroundColor;

  const CachedAvatar({
    super.key,
    this.imageUrl,
    this.radius = 25,
    this.fallbackText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        child: Text(
          fallbackText ?? '?',
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: SizedBox(
          width: radius,
          height: radius,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        child: Text(
          fallbackText ?? '?',
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
