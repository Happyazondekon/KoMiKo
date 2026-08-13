import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'heyhappyproject@gmail.com',
      query: 'subject=Support Komiko',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpSupport),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            context,
            title: l10n.aboutKomiko,
            content: l10n.aboutKomikoDesc,
            cardBg: cardBg,
            border: border,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: l10n.contactUs,
            content: l10n.contactUsDesc,
            cardBg: cardBg,
            border: border,
            action: SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: _launchEmail,
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: Text(
                    'heyhappyproject@gmail.com',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: l10n.termsAndPrivacy,
            content: l10n.termsAndPrivacyDesc,
            cardBg: cardBg,
            border: border,
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Komiko v1.0.2',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required Color cardBg,
    required Color border,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }
}
