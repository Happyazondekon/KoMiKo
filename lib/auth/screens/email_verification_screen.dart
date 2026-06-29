import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:komiko/services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResendEmail = true;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  Future<void> _checkEmailVerified() async {
    final authService = context.read<AuthService>();
    await authService.reloadUser();
    if (authService.currentUser?.emailVerified ?? false) {
      _timer?.cancel();
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (!_canResendEmail) return;
    
    try {
      await context.read<AuthService>().sendEmailVerification();
      setState(() {
        _canResendEmail = false;
        _countdown = 60;
      });
      _startCountdown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        setState(() => _canResendEmail = true);
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = context.read<AuthService>().currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.yellow),
            const SizedBox(height: 24),
            const Text(
              "Check your email",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "We've sent a verification link to $email. Please click the link to verify your account.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _canResendEmail ? _sendVerificationEmail : null,
              child: Text(_canResendEmail ? "Resend Email" : "Resend in ${_countdown}s"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<AuthService>().signOut(),
              child: const Text("Use another account"),
            ),
          ],
        ),
      ),
    );
  }
}
