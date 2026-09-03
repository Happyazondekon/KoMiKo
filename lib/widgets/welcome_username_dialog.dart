import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeUsernameDialog extends StatefulWidget {
  final String initialUsername;
  final VoidCallback onConfirmed;

  const WelcomeUsernameDialog({
    super.key,
    required this.initialUsername,
    required this.onConfirmed,
  });

  static const String prefKey = 'has_confirmed_username';

  /// Vérifie si l'utilisateur doit voir ce dialogue de bienvenue.
  static Future<bool> shouldShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(prefKey) ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Ouvre le dialogue s'il n'a pas encore été confirmé.
  static Future<void> showIfNeeded(BuildContext context) async {
    final needed = await shouldShow();
    if (!needed || !context.mounted) return;

    final userService = context.read<UserService>();
    final current = userService.currentUser?.username ?? 'Komikonaute';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WelcomeUsernameDialog(
        initialUsername: current,
        onConfirmed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }

  @override
  State<WelcomeUsernameDialog> createState() => _WelcomeUsernameDialogState();
}

class _WelcomeUsernameDialogState extends State<WelcomeUsernameDialog> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final newName = _controller.text.trim();
    if (newName.isEmpty) {
      setState(() => _errorText = l10n.usernameEmptyError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final userService = context.read<UserService>();
      if (newName != widget.initialUsername) {
        await userService.updateProfile(username: newName);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(WelcomeUsernameDialog.prefKey, true);

      if (mounted) {
        widget.onConfirmed();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo ou Illustration
              Image.asset(
                'assets/images/Komiko nobg.webp',
                height: 65,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              Text(
                l10n.welcomeUsernameTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeUsernameSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: false,
                maxLength: 30,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  labelText: l10n.usernameFieldLabel,
                  hintText: l10n.usernameFieldHint,
                  errorText: _errorText,
                  counterText: '',
                  prefixIcon: const Icon(Icons.person_rounded,
                      color: AppColors.primary),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          l10n.continueButton,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
