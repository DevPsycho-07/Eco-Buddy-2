// ignore_for_file: dangling_library_doc_comments

/// Reusable error display widget with retry functionality
/// 
/// Use this widget to display errors in a consistent, user-friendly way
/// throughout the app.
/// 
/// Example:
/// ```dart
/// if (error != null) {
///   return ErrorView(
///     message: error,
///     onRetry: () => loadData(),
///   );
/// }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Widget to display error messages with retry option
class ErrorView extends StatelessWidget {
  /// Error message to display
  final String message;
  
  /// Optional callback when user taps retry button
  final VoidCallback? onRetry;
  
  /// Optional custom icon
  final IconData? icon;
  
  /// Optional title (defaults to "Oops!")
  final String? title;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon or animation
            if (icon != null)
              Icon(
                icon,
                size: 80,
                color: Colors.red.shade300,
              )
            else
              SizedBox(
                height: 120,
                child: Lottie.asset(
                  'assets/animations/error.json',
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade300,
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title ?? 'Oops!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
            ),
            
            const SizedBox(height: 12),
            
            // Error message
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              
              // Retry button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget to display empty state messages
class EmptyView extends StatelessWidget {
  /// Message to display
  final String message;
  
  /// Optional subtitle
  final String? subtitle;
  
  /// Optional icon
  final IconData? icon;
  
  /// Optional action button
  final VoidCallback? onAction;
  
  /// Optional action button text
  final String? actionText;

  const EmptyView({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            
            const SizedBox(height: 24),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
            
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Snackbar helper for consistent error messages
class ErrorSnackbar {
  /// Show error snackbar
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
