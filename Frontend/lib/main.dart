// ignore_for_file: dangling_library_doc_comments

/// Main entry point for Eco Daily Score app
/// 
/// Features:
/// - State management with Riverpod
/// - Dependency injection with GetIt
/// - Deep linking with go_router
/// - Offline support with Hive
/// - Image optimization and caching
/// - Enhanced animations and haptics
/// - Responsive design for mobile, tablet, and web
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/di/service_locator.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/permission_request_widget.dart';
import 'services/fcm_service.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('🚀 Starting Eco Daily Score app...');

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  AppLogger.info('✓ Environment variables loaded');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependencies
  try {
    // Setup service locator (dependency injection) - includes OfflineStorage init
    await setupServiceLocator();
    AppLogger.info('✓ Service locator & offline storage initialized');

    // Check authentication state and update router
    final isLoggedIn = await AuthService.isLoggedIn();
    AppRouter.updateAuthState(isLoggedIn);
    AppLogger.info('✓ Auth state checked: isLoggedIn=$isLoggedIn');

    // Initialize Firebase and FCM (optional - will work after user adds google-services.json)
    try {
      await FCMService.initializeFirebase();
      AppLogger.info('✓ Firebase & FCM initialized');
    } catch (e) {
      AppLogger.warning('⚠️ Firebase initialization skipped (add google-services.json to enable notifications): $e');
    }

    // Note: Device token registration happens automatically after login in auth_service.dart
    // No need to call it here

    // Initialize app links (deep linking support)
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen(
      (uri) {
        AppLogger.info('🔗 Deep link received: $uri');
        // Convert deep link to GoRouter path
        // eco-buddy-dotnet://reset-password?token=...&email=... → /reset-password?token=...&email=...
        // eco-buddy-dotnet://verify-email?token=...&email=... → /verify-email?token=...&email=...
        final path = '/${uri.host}${uri.hasQuery ? '?${uri.query}' : ''}';
        AppLogger.info('🔗 Navigating to: $path');
        AppRouter.router.push(path);
      },
      onError: (err) {
        AppLogger.error('Failed to handle app link', error: err);
      },
    );
    AppLogger.info('✓ App links (deep linking) initialized');

    // Run the app
    runApp(
      // Wrap with ProviderScope for Riverpod state management
      const ProviderScope(
        child: EcoDailyScoreApp(),
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.fatal('Failed to initialize app', error: e, stackTrace: stackTrace);
    // Run app in error state
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Main application widget
class EcoDailyScoreApp extends ConsumerWidget {
  const EcoDailyScoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.info('Building EcoDailyScoreApp');

    // Watch the theme mode from provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Eco Daily Score',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Router configuration with deep linking support
      routerConfig: AppRouter.router,
      
      // Builder for additional app-level widgets and permission wrapper
      builder: (context, child) {
        return PermissionRequestWidget(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
