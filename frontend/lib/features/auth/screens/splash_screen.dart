// file: lib/features/auth/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitComplete;

  const SplashScreen({
    super.key,
    required this.onInitComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      widget.onInitComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ① اللوجو
            Image.asset(
              'assets/images/Acadexa_Logo.png',
              width: 180,
              height: 180,
              errorBuilder: (context, error, stackTrace) {
                // Fallback in case of image load failure
                return Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kPrimaryGradient,
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ② اسم التطبيق
            ShaderMask(
              shaderCallback: (bounds) => kPrimaryGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text(
                'Acadexa',
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kWhite, // Required for ShaderMask to work correctly
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ③ tagline
            Text(
              'Smart Academic Advisor Powered by AI',
              style: GoogleFonts.cairo(
                color: kTextMedium,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 48),

            // ④ مؤشر تحميل
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryTeal),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
