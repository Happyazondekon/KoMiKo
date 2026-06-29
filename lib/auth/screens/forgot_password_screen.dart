import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onLoginClicked;
  const ForgotPasswordScreen({super.key, required this.onLoginClicked});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().sendPasswordResetEmail(_emailController.text.trim());
      setState(() => _emailSent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onLoginClicked,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _emailSent ? _buildSuccessView(l10n) : _buildFormView(l10n),
      ),
    );
  }

  Widget _buildFormView(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Reset Password",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          "Enter your email address and we'll send you a link to reset your password.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: l10n.email,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _resetPassword,
          child: _isLoading ? const CircularProgressIndicator() : const Text("Send Link"),
        ),
      ],
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          "Email Sent!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Check your email at ${_emailController.text} for instructions on how to reset your password.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: widget.onLoginClicked,
          child: const Text("Back to Login"),
        ),
      ],
    );
  }
}
