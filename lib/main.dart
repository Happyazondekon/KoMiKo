import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:komiko/theme/app_theme.dart';
import 'package:komiko/providers/theme_provider.dart';
import 'package:komiko/services/localization_service.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/notification_service.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/screens/main_screen.dart';
import 'package:komiko/screens/onboarding_screen.dart';
import 'package:komiko/auth/screens/login_screen.dart';
import 'package:komiko/auth/screens/register_screen.dart';
import 'package:komiko/auth/screens/forgot_password_screen.dart';
import 'package:komiko/auth/screens/email_verification_screen.dart';

import 'package:komiko/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await NotificationService.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        Provider(create: (_) => AuthService()),
        StreamProvider<User?>(
          create: (context) => Provider.of<AuthService>(context, listen: false).userStream,
          initialData: null,
        ),
      ],
      child: const KomikoApp(),
    ),
  );
}

class KomikoApp extends StatelessWidget {
  const KomikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationService = Provider.of<LocalizationService>(context);

    return MaterialApp(
      title: 'Komiko',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localizationService.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;
  bool _showForgotPassword = false;
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      });
    }
  }

  void _toggleAuth() {
    setState(() {
      _showLogin = !_showLogin;
      _showForgotPassword = false;
    });
  }

  void _toggleForgotPassword() {
    setState(() {
      _showForgotPassword = !_showForgotPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wait for onboarding check
    if (_hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show onboarding on first launch
    if (_hasSeenOnboarding == false) {
      return OnboardingScreen(
        onFinished: () => setState(() => _hasSeenOnboarding = true),
      );
    }

    final user = Provider.of<User?>(context);
    final userService = Provider.of<UserService>(context);

    if (user != null) {
      // Trigger profile load (idempotent — safe to call every rebuild)
      userService.loadUserProfile(user.uid);

      // Wait for profile to load before making routing decisions
      if (userService.isLoading || userService.currentUser == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // Allow entry if Firebase Auth email is verified OR the Firestore profile
      // has isVerified=true (covers the Komiko official account and future
      // premium accounts whose emails were verified through another channel).
      final bypassEmailCheck = userService.currentUser!.isVerified;
      if (!user.emailVerified && !bypassEmailCheck) {
        return const EmailVerificationScreen();
      }

      return const MainScreen();
    } else {
      if (_showForgotPassword) {
        return ForgotPasswordScreen(onLoginClicked: _toggleForgotPassword);
      }
      if (_showLogin) {
        return LoginScreen(
          onRegisterClicked: _toggleAuth,
          onForgotPasswordClicked: _toggleForgotPassword,
        );
      } else {
        return RegisterScreen(onLoginClicked: _toggleAuth);
      }
    }
  }
}
