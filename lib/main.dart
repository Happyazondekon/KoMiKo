import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:komiko/theme/app_theme.dart';
import 'package:komiko/providers/theme_provider.dart';
import 'package:komiko/services/localization_service.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/screens/main_screen.dart';
import 'package:komiko/auth/screens/login_screen.dart';
import 'package:komiko/auth/screens/register_screen.dart';
import 'package:komiko/auth/screens/forgot_password_screen.dart';
import 'package:komiko/auth/screens/email_verification_screen.dart';

import 'package:komiko/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();

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
    final user = Provider.of<User?>(context);
    final userService = Provider.of<UserService>(context, listen: false);

    if (user != null) {
      if (!user.emailVerified) {
        return const EmailVerificationScreen();
      }
      userService.loadUserProfile(user.uid);
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
