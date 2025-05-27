// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'utils/theme.dart';
import 'services/preferences_service.dart';
import 'services/audio_manager.dart';
import 'providers/auth_provider.dart';
// import 'services/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await AwesomeNotifications().initialize(
  //   null, // null means use default app icon
  //   [
  //     NotificationChannel(
  //       channelKey: 'basic_channel',
  //       channelName: 'Basic Notifications',
  //       channelDescription: 'Notification channel for basic tests',
  //       defaultColor: Colors.blue,
  //       ledColor: Colors.white,
  //       importance: NotificationImportance.High,
  //     )
  //   ],
  // );

  // final notificationService = NotificationService();
  // await notificationService.initialize();

  final preferencesService = await PreferencesService.getInstance();

  // Initialize audio manager
  final audioManager = AudioManager();
  await audioManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferencesService>(
          create: (_) => preferencesService,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesService>(
      builder: (context, preferences, _) {
        return MaterialApp(
          title: 'Quiz App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: preferences.locale,
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('fr', ''), // French
            Locale('ar', ''), // Arabic
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Show login screen if not authenticated
              if (!authProvider.isSignedIn) {
                return const LoginScreen();
              }
              // Show home screen if authenticated
              return const HomeScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
