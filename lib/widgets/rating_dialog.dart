import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/services/rating_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/widgets/bubble_button.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  static Future<void> show(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RatingDialog(),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) return;

    setState(() => _isSubmitting = true);

    final ratingService = RatingService();

    if (_selectedRating >= 4) {
      // Good rating: try native dialog then mark as rated
      await ratingService.requestNativeReview();
      await ratingService.markAsRated();
    } else {
      // Average/Low: thank and mark as done
      await ratingService.markAsRated();
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.thankYouForRating,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;

    return Material(
      color: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/illustrations/one.webp',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.rateAppTitle.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.rateAppDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    final isSelected = starNumber <= _selectedRating;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRating = starNumber),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 40,
                          color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                
                // Label
                SizedBox(
                  height: 24,
                  child: Text(
                    _getRatingLabel(loc),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedRating >= 4 
                          ? AppColors.success 
                          : _selectedRating > 0 
                              ? AppColors.pink 
                              : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                if (_selectedRating > 0)
                  BubbleButton(
                    onTap: _isSubmitting ? null : _submitRating,
                    label: _selectedRating >= 4 ? loc.rateOnPlayStore : loc.submitRating,
                    fullWidth: true,
                    isLoading: _isSubmitting,
                  )
                else
                  const SizedBox(height: 54),
                  
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.rateLater, style: GoogleFonts.poppins(color: AppColors.textSecondaryDark)),
                    ),
                    TextButton(
                      onPressed: () async {
                        await RatingService().markAsNeverAsk();
                        if (mounted) Navigator.pop(context);
                      },
                      child: Text(loc.noThanks, style: GoogleFonts.poppins(color: AppColors.textSecondaryDark)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(AppLocalizations loc) {
    switch (_selectedRating) {
      case 1: return loc.rating1Star;
      case 2: return loc.rating2Stars;
      case 3: return loc.rating3Stars;
      case 4: return loc.rating4Stars;
      case 5: return loc.rating5Stars;
      default: return loc.tapToRate;
    }
  }
}
