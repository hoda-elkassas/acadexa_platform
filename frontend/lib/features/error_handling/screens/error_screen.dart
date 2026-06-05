// file: lib/features/common/error_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/buttons/ac_button.dart';

// ─── Error type enum ──────────────────────────────────────────────────────
enum AppErrorType {
  network,
  server,
  unauthorized,
  forbidden,
  notFound,
  timeout,
  unknown,
}

// ─── AcErrorScreen ────────────────────────────────────────────────────────
class AcErrorScreen extends StatelessWidget {
  const AcErrorScreen({
    super.key,
    this.errorType = AppErrorType.unknown,
    this.customTitle,
    this.customMessage,
    this.errorCode,
    this.onRetry,
    this.onGoHome,
    this.onReport,
  });

  final AppErrorType errorType;
  final String? customTitle;
  final String? customMessage;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;
  final VoidCallback? onReport;

  String get _title {
    if (customTitle != null) return customTitle!;
    return switch (errorType) {
      AppErrorType.network => 'لا يوجد اتصال بالإنترنت',
      AppErrorType.server => 'خطأ في الخادم',
      AppErrorType.unauthorized => 'غير مصرح لك',
      AppErrorType.forbidden => 'ليس لديك صلاحية',
      AppErrorType.notFound => 'الصفحة غير موجودة',
      AppErrorType.timeout => 'انتهت المهلة',
      AppErrorType.unknown => 'حدث خطأ ما',
    };
  }

  String get _message {
    if (customMessage != null) return customMessage!;
    return switch (errorType) {
      AppErrorType.network => 'يرجى التحقق من اتصال الشبكة والمحاولة مرة أخرى',
      AppErrorType.server => 'حدث عطل فني في نظامنا. نعمل على حله حالياً',
      AppErrorType.unauthorized =>
        'يرجى تسجيل الدخول مرة أخرى للوصول إلى هذه الصفحة',
      AppErrorType.forbidden => 'لا تملك الصلاحية للوصول إلى هذه البيانات',
      AppErrorType.notFound => 'عذراً، الصفحة التي تبحث عنها غير متوفرة',
      AppErrorType.timeout =>
        'استغرق الاتصال وقتاً طويلاً. يرجى المحاولة لاحقاً',
      AppErrorType.unknown => 'حدث خطأ غير معروف. يرجى المحاولة لاحقاً',
    };
  }

  IconData get _icon => switch (errorType) {
    AppErrorType.network => Icons.wifi_off_rounded,
    AppErrorType.server => Icons.dns_outlined,
    AppErrorType.unauthorized => Icons.lock_outline_rounded,
    AppErrorType.forbidden => Icons.block_rounded,
    AppErrorType.notFound => Icons.search_off_rounded,
    AppErrorType.timeout => Icons.timer_off_outlined,
    AppErrorType.unknown => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.danger50,
                      borderRadius: AppRadius.brXl,
                    ),
                    child: Icon(_icon, size: 48, color: AppColors.danger500),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _title,
                    style: AppTypography.h2,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  if (errorCode != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.brXs,
                      ),
                      child: Text(
                        'كود الخطأ: $errorCode',
                        style: AppTypography.caption,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (onRetry != null)
                    AcButton(
                      label: 'إعادة المحاولة',
                      onPressed: onRetry,
                      leadingIcon: const Icon(Icons.refresh_rounded),
                      isFullWidth: true,
                      useGradient: true,
                    ),
                  if (onGoHome != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    AcButton(
                      label: 'العودة للرئيسية',
                      onPressed: onGoHome,
                      variant: AcButtonVariant.ghost,
                      isFullWidth: true,
                    ),
                  ],
                  if (onReport != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: onReport,
                      child: Text(
                        'الإبلاغ عن المشكلة',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textMuted,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'إذا استمرت المشكلة، يرجى الاتصال بالدعم الفني',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
