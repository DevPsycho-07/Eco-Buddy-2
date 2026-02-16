import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../services/secure_profile_picture_service.dart';
import '../utils/app_logger.dart';

/// Widget to display encrypted profile pictures with automatic decryption
/// 
/// Fetches and decrypts profile pictures through secure API endpoint
class SecureProfilePictureAvatar extends StatefulWidget {
  final int? userId;
  final double radius;
  final Color? backgroundColor;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SecureProfilePictureAvatar({
    super.key,
    this.userId,
    this.radius = 40,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<SecureProfilePictureAvatar> createState() => _SecureProfilePictureAvatarState();
}

class _SecureProfilePictureAvatarState extends State<SecureProfilePictureAvatar> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SecureProfilePictureAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final bytes = await SecureProfilePictureService.getProfilePicture(
        userId: widget.userId,
      );

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load profile picture', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: widget.backgroundColor ?? Colors.grey[300],
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
    }

    if (_hasError || _imageBytes == null) {
      return widget.errorWidget ??
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: widget.backgroundColor ?? Colors.grey[200],
            child: Padding(
              padding: EdgeInsets.all(widget.radius * 0.25), // Add padding to match image appearance
              child: Icon(
                Icons.person,
                size: widget.radius * 1.0,
                color: Colors.grey[400],
              ),
            ),
          );
    }

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      backgroundImage: MemoryImage(_imageBytes!),
    );
  }
}
