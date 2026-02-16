import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/email_service.dart';
import '../../core/utils/app_logger.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String token;

  const VerifyEmailPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> with TickerProviderStateMixin {
  bool _isVerifying = true;
  bool _verificationSuccess = false;
  String _verificationMessage = 'Verifying your email...';
  bool _canResend = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _verifyEmail();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  Future<void> _verifyEmail() async {
    try {
      AppLogger.info('🔐 Verifying email with token: ${widget.token.substring(0, 10)}...');
      
      final result = await EmailService.verifyEmail(
        email: widget.email,
        token: widget.token,
      );

      if (mounted) {
        if (result['success']) {
          AppLogger.info('✅ Email verified successfully');
          setState(() {
            _isVerifying = false;
            _verificationSuccess = true;
            _verificationMessage = 'Email verified successfully!';
          });

          // Auto-redirect to home after 3 seconds
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            context.go('/home');
          }
        } else {
          AppLogger.error('❌ Verification failed: ${result['error']}');
          setState(() {
            _isVerifying = false;
            _verificationSuccess = false;
            _verificationMessage = result['error'] ?? 'Verification failed';
            _canResend = true;
          });
        }
      }
    } catch (e) {
      AppLogger.error('❌ Exception during email verification: $e');
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verificationSuccess = false;
          _verificationMessage = 'Verification error: ${e.toString()}';
          _canResend = true;
        });
      }
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _canResend = false;
    });

    try {
      final result = await EmailService.resendVerificationEmail(widget.email);

      if (mounted) {
        if (result['success']) {
          AppLogger.info('✅ Verification email resent');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email resent! Check your inbox.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Allow resend again after 60 seconds
          await Future.delayed(const Duration(seconds: 60));
          if (mounted) {
            setState(() {
              _canResend = true;
            });
          }
        } else {
          AppLogger.error('❌ Resend failed: ${result['error']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ?? 'Failed to resend email'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _canResend = true;
            });
          }
        }
      }
    } catch (e) {
      AppLogger.error('❌ Exception during resend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _canResend = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isVerifying)
                  // Loading state
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withValues(alpha: 0.1),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Verifying Your Email',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please wait while we verify your email address...',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else if (_verificationSuccess)
                  // Success state
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withValues(alpha: 0.1),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            size: 50,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Email Verified!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your email has been verified successfully.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'You can now access all features of Eco Daily Score!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => context.go('/home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Go to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // Error state
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withValues(alpha: 0.1),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Verification Failed',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _verificationMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'This link may have expired. You can request a new verification email below.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _canResend ? _resendVerification : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _canResend
                                ? 'Resend Verification Email'
                                : 'Resending... (60s)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
