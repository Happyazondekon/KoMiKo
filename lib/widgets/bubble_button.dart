import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/theme/bubble_theme.dart';

export 'package:komiko/theme/bubble_theme.dart' show BubbleVariant;

enum BubbleSize { small, medium, large }

class BubbleButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onTap;
  final BubbleVariant variant;
  final bool fullWidth;
  final BubbleSize size;
  final bool isLoading;

  const BubbleButton({
    super.key,
    this.label,
    this.child,
    this.onTap,
    this.variant = BubbleVariant.primary,
    this.fullWidth = false,
    this.size = BubbleSize.medium,
    this.isLoading = false,
  }) : assert(label != null || child != null,
            'BubbleButton requires either label or child');

  @override
  State<BubbleButton> createState() => _BubbleButtonState();
}

class _BubbleButtonState extends State<BubbleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pressAnim;

  static const double _solidOffset = 5.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _pressAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDisabled => widget.onTap == null || widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (_isDisabled) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (_isDisabled) return;
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  double get _height {
    switch (widget.size) {
      case BubbleSize.small:  return 40.0;
      case BubbleSize.medium: return 54.0;
      case BubbleSize.large:  return 64.0;
    }
  }

  double get _horizontalPadding {
    switch (widget.size) {
      case BubbleSize.small:  return 16.0;
      case BubbleSize.medium: return 28.0;
      case BubbleSize.large:  return 36.0;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case BubbleSize.small:  return 14.0;
      case BubbleSize.medium: return 16.0;
      case BubbleSize.large:  return 18.0;
    }
  }

  double get _radius {
    switch (widget.size) {
      case BubbleSize.small:  return BubbleTheme.radiusMedium;
      case BubbleSize.medium: return BubbleTheme.radiusLarge;
      case BubbleSize.large:  return BubbleTheme.radiusPill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;

    return AnimatedBuilder(
      animation: _pressAnim,
      builder: (context, _) {
        final currentOffset = _isDisabled
            ? 1.0
            : _solidOffset * (1.0 - _pressAnim.value);
        final translateY = _isDisabled
            ? 0.0
            : _solidOffset * _pressAnim.value;

        final shadows = _isDisabled
            ? BubbleTheme.disabledShadows()
            : BubbleTheme.shadowsFor(
                shadowColor: variant.shadowColor,
                solidOffset: currentOffset,
              );

        final bgColor = _isDisabled ? const Color(0xFFCCCCCC) : variant.color;

        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: _height,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: shadows,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              variant.foreground,
                            ),
                          ),
                        )
                      : widget.child ??
                          Text(
                            widget.label!,
                            style: GoogleFonts.poppins(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.w800,
                              color: variant.foreground,
                              letterSpacing: 0.3,
                            ),
                          ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
