// file: lib/shared/widgets/inputs/ac_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';

// ─── AcTextField ──────────────────────────────────────────────────────────
class AcTextField extends StatefulWidget {
  const AcTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.textDirection,
    this.onTap,
    this.initialValue,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextDirection? textDirection;
  final VoidCallback? onTap;
  final String? initialValue;

  @override
  State<AcTextField> createState() => _AcTextFieldState();
}

typedef AcInputField = AcTextField;

class _AcTextFieldState extends State<AcTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (!widget.enabled) return AppColors.neutral200;
    if (widget.errorText != null) return AppColors.danger500;
    if (_isFocused) return AppColors.primary500;
    return AppColors.border;
  }

  double get _borderWidth {
    if (widget.errorText != null || _isFocused) return 2;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: AppRadius.brInput,
            border: Border.all(color: _borderColor, width: _borderWidth),
            color: widget.enabled ? AppColors.surface : AppColors.neutral50,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            textDirection: widget.textDirection ?? TextDirection.rtl,
            onTap: widget.onTap,
            style: AppTypography.bodyMedium.copyWith(
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: const IconThemeData(
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconTheme(
                      data: const IconThemeData(
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      child: widget.suffixIcon!,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.inputPaddingH,
                vertical: AppSpacing.inputPaddingV,
              ),
              counterText: '',
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: AppColors.danger500,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.danger500,
                  ),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(widget.helperText!, style: AppTypography.bodySmall),
        ],
      ],
    );
  }
}

// ─── AcPasswordField ─────────────────────────────────────────────────────
class AcPasswordField extends StatefulWidget {
  const AcPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.showStrengthIndicator = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final bool showStrengthIndicator;

  @override
  State<AcPasswordField> createState() => _AcPasswordFieldState();
}

class _AcPasswordFieldState extends State<AcPasswordField> {
  bool _visible = false;
  int _strength = 0; // 0-4

  int _calcStrength(String p) {
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[a-z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  Color get _strengthColor {
    if (_strength <= 1) return AppColors.danger500;
    if (_strength == 2) return AppColors.warning500;
    if (_strength == 3) return AppColors.warning600;
    return AppColors.success500;
  }

  String get _strengthLabel {
    if (_strength <= 1) return 'ضعيف';
    if (_strength == 2) return 'مقبول';
    if (_strength == 3) return 'جيد';
    return 'قوي';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AcTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint,
          errorText: widget.errorText,
          obscureText: !_visible,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          textDirection: TextDirection.ltr,
          onChanged: (v) {
            if (widget.showStrengthIndicator) {
              setState(() => _strength = _calcStrength(v));
            }
            widget.onChanged?.call(v);
          },
          onSubmitted: widget.onSubmitted,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _visible = !_visible),
            child: Icon(
              _visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        if (widget.showStrengthIndicator && _strength > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: i == 0 ? 0 : AppSpacing.xxs),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < _strength
                        ? _strengthColor
                        : AppColors.neutral200,
                    borderRadius: AppRadius.brPill,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _strengthLabel,
            style: AppTypography.caption.copyWith(color: _strengthColor),
          ),
        ],
      ],
    );
  }
}

// ─── AcSearchField ────────────────────────────────────────────────────────
class AcSearchField extends StatelessWidget {
  const AcSearchField({
    super.key,
    this.controller,
    this.hint = 'بحث...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.isLoading = false,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool isLoading;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AcTextField(
      controller: controller,
      hint: hint,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search_rounded),
      suffixIcon: onClear != null
          ? GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close_rounded, size: 18),
            )
          : null,
    );
  }
}

// ─── AcOtpField ───────────────────────────────────────────────────────────
class AcOtpField extends StatefulWidget {
  const AcOtpField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.errorText,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final String? errorText;
  final bool enabled;

  @override
  State<AcOtpField> createState() => _AcOtpFieldState();
}

class _AcOtpFieldState extends State<AcOtpField>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 6.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(AcOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String get _currentValue => _controllers.map((c) => c.text).join();

  void _onDigitInput(int index, String value) {
    if (value.length > 1) {
      // handle paste
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < widget.length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= widget.length) {
        _focusNodes.last.requestFocus();
        widget.onCompleted(_currentValue);
      }
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    widget.onChanged?.call(_currentValue);
    if (_currentValue.length == widget.length) {
      widget.onCompleted(_currentValue);
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  child: _OtpCell(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    hasError: widget.hasError,
                    enabled: widget.enabled,
                    onInput: (v) => _onDigitInput(i, v),
                    onBackspace: () => _onBackspace(i),
                  ),
                );
              }),
            ),
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OtpCell extends StatefulWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.enabled,
    required this.onInput,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onInput;
  final VoidCallback onBackspace;

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: AppRadius.brSm,
        color: AppColors.surface,
        border: Border.all(
          color: widget.hasError
              ? AppColors.danger500
              : _focused
              ? AppColors.primary500
              : AppColors.border,
          width: _focused || widget.hasError ? 2 : 1.5,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent &&
              e.logicalKey == LogicalKeyboardKey.backspace &&
              widget.controller.text.isEmpty) {
            widget.onBackspace();
          }
        },
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTypography.h3.copyWith(letterSpacing: 0),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onInput,
        ),
      ),
    );
  }
}

// ─── AcDropdownField ─────────────────────────────────────────────────────
class AcDropdownField<T> extends StatelessWidget {
  const AcDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brInput,
            border: Border.all(
              color: errorText != null ? AppColors.danger500 : AppColors.border,
              width: errorText != null ? 2 : 1.5,
            ),
            color: enabled ? AppColors.surface : AppColors.neutral50,
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                items: items,
                onChanged: enabled ? onChanged : null,
                isExpanded: true,
                hint: hint != null
                    ? Text(
                        hint!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      )
                    : null,
                style: AppTypography.bodyMedium,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
                borderRadius: AppRadius.brDropdown,
                elevation: 4,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            errorText!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.danger500),
          ),
        ],
      ],
    );
  }
}
