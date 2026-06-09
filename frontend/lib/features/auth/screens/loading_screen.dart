// file: lib/features/auth/screens/loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  final String? message;
  final double? progress;
  final VoidCallback? onCancel;
  final Duration timeoutDuration;
  final VoidCallback? onTimeout;

  const LoadingScreen({
    super.key,
    this.message,
    this.progress,
    this.onCancel,
    this.timeoutDuration = const Duration(seconds: 10),
    this.onTimeout,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _showCancelButton = false;
  Timer? _cancelTimer;
  Timer? _timeoutTimer;
  int _dotsCount = 0;
  Timer? _dotsTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Show cancel button after 5 seconds of loading
    _cancelTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showCancelButton = true;
        });
      }
    });

    // Handle timeout
    _timeoutTimer = Timer(widget.timeoutDuration, () {
      if (mounted && widget.onTimeout != null) {
        widget.onTimeout!();
      }
    });

    // Dots animation
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotsCount = (_dotsCount + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _cancelTimer?.cancel();
    _timeoutTimer?.cancel();
    _dotsTimer?.cancel();
    super.dispose();
  }

  String get _dots => '.' * _dotsCount;

  @override
  Widget build(BuildContext context) {
    final displayMessage = widget.message ?? 'جاري التحميل';
    final hasProgress = widget.progress != null;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: Stack(
        children: [
          // Top Progress Bar
          if (hasProgress)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: widget.progress,
                backgroundColor: kLightBlue.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryTeal),
                minHeight: 4,
              ),
            ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gradient Rotating Spinner
                  RotationTransition(
                    turns: _rotationController,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return SweepGradient(
                          startAngle: 0.0,
                          endAngle: 3.14 * 2,
                          colors: [
                            kPrimaryTeal.withValues(alpha: 0.1),
                            kPrimaryTeal,
                          ],
                          stops: const [0.0, 1.0],
                        ).createShader(rect);
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 8.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Loading text with animated dots
                  Text(
                    '$displayMessage$_dots',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),

                  if (hasProgress) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${(widget.progress! * 100).toInt()}%',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryTeal,
                      ),
                    ),
                  ],

                  // Long loading hint
                  if (_showCancelButton) ...[
                    const SizedBox(height: 16),
                    Text(
                      'يبدو أن العملية تستغرق وقتاً أطول من المعتاد',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: kTextMedium,
                      ),
                    ),
                  ],

                  const SizedBox(height: 48),

                  // Cancel Button (fades in after 5s)
                  AnimatedOpacity(
                    opacity: _showCancelButton && widget.onCancel != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _showCancelButton && widget.onCancel != null
                        ? OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimaryBlue,
                              side: const BorderSide(color: kDivider, width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إلغاء العملية',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(height: 48),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
