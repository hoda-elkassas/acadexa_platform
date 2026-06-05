// file: lib/features/auth/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_shadows.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onInitComplete,
    this.onInitError,
    this.initFuture,
  });

  final VoidCallback onInitComplete;
  final void Function(Object error)? onInitError;
  final Future<void> Function()? initFuture;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textSlide;

  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _textOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween(
      begin: 16.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _runInit();
  }

  Future<void> _runInit() async {
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textCtrl.forward();

    if (widget.initFuture != null) {
      try {
        await widget.initFuture!();
        if (mounted) widget.onInitComplete();
      } catch (e) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
          widget.onInitError?.call(e);
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) widget.onInitComplete();
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.splash),
        child: SafeArea(
          child: Column(
            children: [
              // ── Progress bar ────────────────────────────────────
              if (!_hasError)
                LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary300.withValues(alpha: 0.4),
                  minHeight: 2,
                ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo ──────────────────────────────────
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              boxShadow: AppShadows.xl,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: AppGradients.primaryDiagonal,
                                  borderRadius: AppRadius.brMd,
                                ),
                                child: const Center(
                                  child: Text(
                                    'A',
                                    style: TextStyle(
                                      color: AppColors.neutral0,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Brand name + tagline ───────────────────
                      FadeTransition(
                        opacity: _textOpacity,
                        child: AnimatedBuilder(
                          animation: _textSlide,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: child,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Acadexa',
                                style: AppTypography.displayMedium.copyWith(
                                  foreground: Paint()
                                    ..shader =
                                        const LinearGradient(
                                          colors: [
                                            AppColors.primary500,
                                            AppColors.secondary700,
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 50),
                                        ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'نظامك الخبير.. لإرشاد أكاديمي ذكي.',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // ── Loading / Error ───────────────────────
                      if (_hasError)
                        _SplashError(
                          message: _errorMessage,
                          onRetry: () {
                            setState(() {
                              _hasError = false;
                              _errorMessage = null;
                            });
                            _runInit();
                          },
                        )
                      else
                        const _SplashLoader(),
                    ],
                  ),
                ),
              ),

              // ── Version ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  'الإصدار: 1.0.0',
                  style: AppTypography.caption,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashLoader extends StatefulWidget {
  const _SplashLoader();

  @override
  State<_SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<_SplashLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dot;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dot = Tween(begin: 0.0, end: 3.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary500,
            backgroundColor: AppColors.primary100,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedBuilder(
          animation: _dot,
          builder: (context, child) {
            final dots = '.' * (_dot.value.floor() + 1);
            return Text(
              'جاري التحميل$dots',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textDirection: TextDirection.rtl,
            );
          },
        ),
      ],
    );
  }
}

class _SplashError extends StatelessWidget {
  const _SplashError({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          size: 32,
          color: AppColors.danger500,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'فشل الاتصال بالخادم',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.danger500),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brPill,
              border: Border.all(color: AppColors.primary500),
            ),
            child: Text(
              'إعادة المحاولة',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary500,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ],
    );
  }
}
