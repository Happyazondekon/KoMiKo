import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:komiko/services/remote_config_service.dart';
import 'package:komiko/services/purchase_service.dart';
import 'package:komiko/screens/update_required_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await NotificationService.init();

  // Initialize Remote Config
  await RemoteConfigService().initialize();

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) {
          final ps = PurchaseService();
          ps.initialize(); // Démarre l'initialisation en arrière-plan
          return ps;
        }),
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
  bool _updateRequired = false;
  bool _checkingUpdate = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    final required = await RemoteConfigService().isUpdateRequired();
    if (mounted) {
      setState(() {
        _updateRequired = required;
        _checkingUpdate = false;
      });
    }
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
    // Show splash-like loader while checking for update or onboarding
    if (_checkingUpdate || _hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Force update screen if required
    if (_updateRequired) {
      return const UpdateRequiredScreen();
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
      // Trigger profile load safely after the current build frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          userService.loadUserProfile(user.uid);
        }
      });

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
