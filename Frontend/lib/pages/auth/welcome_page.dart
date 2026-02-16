import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../../services/guest_service.dart';
import '../../services/auth_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final isGuest = await GuestService.isGuestSession();
      
      if (mounted) {
        if (isLoggedIn || isGuest) {
          // Navigate to app shell using go_router
          context.go('/home');
        } else {
          setState(() {
            _isCheckingAuth = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  Future<void> _startGuestMode(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );

    try {
      // First, logout any existing authenticated session
      await AuthService.logout();
      
      // Get or create unique guest ID for this device
      final guestId = await GuestService.getOrCreateGuestId();
      await GuestService.startGuestSession();
      
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        
        // Show guest ID notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome, Guest! Your device ID: ${guestId.substring(guestId.length - 8).toUpperCase()}',
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 3),
          ),
        );
        
        if (context.mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting guest mode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking authentication
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1B5E20),
                    const Color(0xFF2E7D32),
                    const Color(0xFF388E3C),
                  ]
                : [
                    const Color(0xFFF1F8E9),
                    const Color(0xFFE8F5E9),
                    const Color(0xFFC8E6C9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo
                ClipOval(
                  child: Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: const BoxDecoration(
                      // color: const Color(0xFF43A047).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/icon/Logo.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // const SizedBox(height: 15),
                // App Name
                Text(
                  'Eco Buddy',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2E7D32),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 19),
                Text(
                  '🌍 Track, Reduce, Transform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.9) 
                        : const Color(0xFF2E7D32).withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                // const Spacer(flex: 1),
                const SizedBox(height: 30),
                Text(
                  '🌐 Live Eco Score • Personal Impact',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.9) 
                        : const Color(0xFF2E7D32).withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark 
                          ? const Color(0xFF66BB6A) 
                          : const Color(0xFF43A047),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      elevation: 2,
                      shadowColor: isDark 
                          ? const Color(0xFF66BB6A).withValues(alpha: 0.3) 
                          : const Color(0xFF43A047).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Start Your Impact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark 
                          ? const Color(0xFF81C784) 
                          : const Color(0xFF43A047),
                      side: BorderSide(
                        color: isDark 
                            ? const Color(0xFF81C784) 
                            : const Color(0xFF43A047),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Create an Eco Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Guest Button
                TextButton(
                  onPressed: () => _startGuestMode(context),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark 
                        ? const Color(0xFF81C784) 
                        : const Color(0xFF43A047),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_sharp,
                        color: isDark 
                            ? const Color(0xFF81C784).withValues(alpha: 0.9) 
                            : const Color(0xFF43A047).withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Explore as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark 
                              ? const Color(0xFF81C784).withValues(alpha: 0.9) 
                              : const Color(0xFF43A047).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Footer
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.6) 
                        : const Color(0xFF2E7D32).withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
