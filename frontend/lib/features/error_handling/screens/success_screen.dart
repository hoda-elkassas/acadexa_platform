// file: lib/features/error_handling/screens/success_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;
  final Duration autoCloseDuration;
  final VoidCallback? onAutoClose;

  const SuccessScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.primaryButtonLabel,
    this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
    this.autoCloseDuration = const Duration(seconds: 3),
    this.onAutoClose,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _animController.forward();

    // Auto-close if no buttons are provided or if explicitly requested
    if (widget.primaryButtonLabel == null && widget.secondaryButtonLabel == null) {
      _autoCloseTimer = Timer(widget.autoCloseDuration, () {
        if (mounted) {
          if (widget.onAutoClose != null) {
            widget.onAutoClose!();
          } else {
            Navigator.of(context).pop();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPrimary = widget.primaryButtonLabel != null && widget.onPrimaryPressed != null;
    final hasSecondary = widget.secondaryButtonLabel != null && widget.onSecondaryPressed != null;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ① Icon success container with elastic scale animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: kSuccess.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kSuccess.withValues(alpha: 0.2),
                      width: 4,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: kSuccess,
                      size: 64,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ② Title & Subtitle with fade/slide-up transition effect
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.subtitle!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: kTextMedium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ③ Buttons section
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    if (hasPrimary)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: widget.onPrimaryPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: kWhite,
                            elevation: 2,
                            shadowColor: kPrimaryBlue.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.primaryButtonLabel!,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    if (hasPrimary && hasSecondary) const SizedBox(height: 16),

                    if (hasSecondary)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: widget.onSecondaryPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryBlue,
                            side: const BorderSide(color: kDivider, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.secondaryButtonLabel!,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    if (!hasPrimary && !hasSecondary)
                      Text(
                        'سيتم الانتقال تلقائياً خلال لحظات...',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: kTextLight,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
