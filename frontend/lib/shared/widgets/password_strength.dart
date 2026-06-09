// file: lib/shared/widgets/password_strength.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%]'))) strength++;

    final colors = [kError, kWarning, kWarning, kSuccess, kSuccess];
    final labels = ['', 'ضعيفة', 'ضعيفة', 'متوسطة', 'قوية'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(left: i < 3 ? 4 : 0), // Changed right to left for RTL layout friendliness
              decoration: BoxDecoration(
                color: i < strength ? colors[strength] : kDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'قوة كلمة المرور: ${labels[strength]}',
            style: GoogleFonts.cairo(
              color: colors[strength],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
