# Acadexa — Auth Screens Specification
> **للـ AI اللي هينفذ:** اقرأ الـ Design Tokens أولاً قبل أي شاشة، وطبّقها على كل عنصر.

---

## 🎨 Design Tokens

### الألوان (من اللوجو والـ color palette)
```dart
// ── Primary Palette ──────────────────────────────
const kPrimaryBlue     = Color(0xFF0D47A1); // أزرق غامق — الـ primary actions
const kPrimaryTeal     = Color(0xFF1B8FA6); // تيل — gradient ثاني / accents
const kDarkNavy        = Color(0xFF0D3B5E); // نيفي — headers / AppBar
const kMediumTeal      = Color(0xFF5BA4AF); // تيل متوسط — secondary elements
const kLightBlue       = Color(0xFFADD8E6); // فاتح — backgrounds / hints
const kScaffoldBg      = Color(0xFFF5F9FA); // خلفية الشاشات (off-white مع صبغة تيل)

// ── Neutral ──────────────────────────────────────
const kTextDark        = Color(0xFF0D1B2A); // النصوص الأساسية
const kTextMedium      = Color(0xFF546E7A); // النصوص الثانوية / labels
const kTextLight       = Color(0xFF90A4AE); // placeholder / hints
const kDivider         = Color(0xFFCFD8DC); // فواصل وحدود خفيفة
const kWhite           = Color(0xFFFFFFFF);

// ── Semantic ─────────────────────────────────────
const kError           = Color(0xFFD32F2F); // خطأ
const kSuccess         = Color(0xFF2E7D32); // نجاح
const kWarning         = Color(0xFFF57C00); // تحذير
```

### الـ Gradient الأساسي (للأزرار والـ AppBar)
```dart
const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF0D47A1), Color(0xFF1B8FA6)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
```

### Typography
```dart
// Font: Cairo (عربي) — استخدم google_fonts: Cairo
// Fallback لو Cairo مش متاح: Tajawal

const kFontFamily = 'Cairo';

// Sizes
// Display  : 28sp Bold   — عناوين الشاشات الكبيرة
// Title    : 22sp SemiBold — عناوين الأقسام
// Body     : 16sp Regular  — النصوص العادية
// Caption  : 13sp Regular  — hints / labels ثانوية
// Button   : 16sp Bold     — نص الأزرار
```

### الـ Spacing & Radius
```dart
const kRadiusSmall  = 8.0;
const kRadiusMedium = 12.0;
const kRadiusLarge  = 16.0;
const kRadiusXL     = 24.0;   // بطاقات كبيرة

const kSpacingXS    = 4.0;
const kSpacingS     = 8.0;
const kSpacingM     = 16.0;
const kSpacingL     = 24.0;
const kSpacingXL    = 32.0;
const kSpacingXXL   = 48.0;
```

### الـ TextFormField الموحّد (AppTextField)
```dart
// استخدم هذا الـ widget في كل الشاشات بدل تكرار الـ decoration
InputDecoration(
  filled: true,
  fillColor: kWhite,
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  hintStyle: TextStyle(color: kTextLight, fontFamily: kFontFamily, fontSize: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadiusMedium),
    borderSide: BorderSide(color: kDivider),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadiusMedium),
    borderSide: BorderSide(color: kDivider),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadiusMedium),
    borderSide: BorderSide(color: kPrimaryBlue, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadiusMedium),
    borderSide: BorderSide(color: kError),
  ),
  prefixIconColor: kTextMedium,
)
```

### الـ PrimaryButton الموحّد
```dart
// زر أساسي gradient — استخدم في كل الشاشات
Container(
  width: double.infinity,
  height: 52,
  decoration: BoxDecoration(
    gradient: kPrimaryGradient,
    borderRadius: BorderRadius.circular(kRadiusMedium),
    boxShadow: [BoxShadow(
      color: kPrimaryBlue.withOpacity(0.3),
      blurRadius: 8, offset: Offset(0, 4),
    )],
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMedium)),
    ),
    onPressed: onPressed,
    child: Text(label, style: TextStyle(
      color: kWhite, fontSize: 16,
      fontWeight: FontWeight.bold, fontFamily: kFontFamily,
    )),
  ),
)
```

---

## 📱 الشاشات

---

## Screen 01 — SplashScreen

### الهدف
عرض اللوجو وتحميل الـ session من Supabase، ثم توجيه المستخدم.

### التوجيه بعد الـ Splash
```
Supabase.auth.currentSession != null
  → HomeScreen (الشاشة الرئيسية حسب الـ role)
  
Supabase.auth.currentSession == null
  → LoginScreen
```

### الـ UI
```
Scaffold(
  backgroundColor: kScaffoldBg,
  body: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // ① اللوجو — Image.asset('assets/images/acadexa_logo.png')
      //    width: 180, height: 180
      //    مع ShaderMask أو الصورة الأصلية مباشرة

      SizedBox(height: 24),

      // ② اسم التطبيق
      Text('Acadexa',
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          foreground: Paint()..shader = kPrimaryGradient.createShader(...),
        ),
      ),

      SizedBox(height: 8),

      // ③ tagline
      Text('Smart Academic Advisor Powered by AI',
        style: TextStyle(
          color: kTextMedium, fontSize: 13, fontFamily: kFontFamily,
        ),
      ),

      SizedBox(height: 48),

      // ④ مؤشر تحميل
      CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(kPrimaryTeal),
        strokeWidth: 2,
      ),
    ],
  ),
)
```

### المنطق
```dart
@override
void initState() {
  super.initState();
  _checkSession();
}

Future<void> _checkSession() async {
  await Future.delayed(Duration(milliseconds: 1500)); // حد أدنى للـ splash
  final session = Supabase.instance.client.auth.currentSession;
  if (!mounted) return;
  if (session != null) {
    context.go('/home');
  } else {
    context.go('/login');
  }
}
```

### الأصول المطلوبة
- `assets/images/acadexa_logo.png` — اللوجو بخلفية شفافة

---

## Screen 02 — LoginScreen

### الهدف
تسجيل الدخول بالإيميل وكلمة السر عن طريق Supabase Auth.

### الـ UI Layout
```
Scaffold(
  backgroundColor: kScaffoldBg,
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(height: 48),

          // ① اللوجو + اسم التطبيق (نفس الـ Splash بس أصغر)
          Image.asset('assets/images/acadexa_logo.png', width: 100, height: 100),
          SizedBox(height: 12),
          Text('Acadexa', style: TextStyle(
            fontFamily: kFontFamily, fontSize: 26,
            fontWeight: FontWeight.bold, color: kPrimaryBlue,
          )),

          SizedBox(height: 8),

          // ② subtitle
          Text('مرحباً بك، سجّل دخولك للمتابعة',
            style: TextStyle(color: kTextMedium, fontFamily: kFontFamily, fontSize: 14),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 40),

          // ③ حقل الإيميل
          AppTextField(
            label: 'البريد الإلكتروني',
            hint: 'example@university.edu',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            validator: (v) => v!.isEmpty ? 'أدخل البريد الإلكتروني' : null,
          ),

          SizedBox(height: 16),

          // ④ حقل كلمة السر
          AppTextField(
            label: 'كلمة المرور',
            hint: '••••••••',
            obscureText: _obscure,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            controller: _passController,
            validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة' : null,
          ),

          SizedBox(height: 8),

          // ⑤ نسيت كلمة المرور (يمين)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: Text('نسيت كلمة المرور؟',
                style: TextStyle(color: kPrimaryTeal, fontFamily: kFontFamily, fontSize: 14),
              ),
            ),
          ),

          SizedBox(height: 24),

          // ⑥ زر تسجيل الدخول
          PrimaryButton(
            label: 'تسجيل الدخول',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),

          SizedBox(height: 24),

          // ⑦ رسالة الخطأ (تظهر فقط لو في error)
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kError.withOpacity(0.08),
                borderRadius: BorderRadius.circular(kRadiusSmall),
                border: Border.all(color: kError.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.error_outline, color: kError, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text(_errorMessage!,
                  style: TextStyle(color: kError, fontFamily: kFontFamily, fontSize: 13),
                )),
              ]),
            ),

        ],
      ),
    ),
  ),
)
```

### المنطق
```dart
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passController  = TextEditingController();
bool _isLoading = false;
bool _obscure   = true;
String? _errorMessage;

Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() { _isLoading = true; _errorMessage = null; });

  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email:    _emailController.text.trim(),
      password: _passController.text,
    );

    if (response.user != null) {
      // جيب الـ role من جدول app_users
      final userData = await Supabase.instance.client
        .from('app_users')
        .select('role, full_name')
        .eq('id', response.user!.id)
        .single();

      // احفظ الـ role في الـ Provider/Riverpod/GetX
      // ثم روّح للـ Home
      if (mounted) context.go('/home');
    }
  } on AuthException catch (e) {
    setState(() {
      _errorMessage = _mapAuthError(e.message);
    });
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

String _mapAuthError(String message) {
  if (message.contains('Invalid login credentials'))
    return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
  if (message.contains('Email not confirmed'))
    return 'يرجى تأكيد بريدك الإلكتروني أولاً';
  return 'حدث خطأ، يرجى المحاولة مرة أخرى';
}
```

---

## Screen 03 — ForgotPasswordScreen

### الهدف
المستخدم يدخل إيميله، التطبيق يبعت OTP عن طريق Supabase.

### الـ UI Layout
```
Scaffold(
  backgroundColor: kScaffoldBg,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: BackButton(color: kPrimaryBlue),
    title: Text('استعادة كلمة المرور',
      style: TextStyle(color: kTextDark, fontFamily: kFontFamily, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  ),
  body: Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 16),

        // ① أيقونة توضيحية
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: kLightBlue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_reset, color: kPrimaryBlue, size: 40),
          ),
        ),

        SizedBox(height: 24),

        // ② عنوان وشرح
        Text('أدخل بريدك الإلكتروني',
          style: TextStyle(fontFamily: kFontFamily, fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark),
        ),
        SizedBox(height: 8),
        Text('سنرسل إليك رمز التحقق (OTP) على بريدك الإلكتروني لإعادة تعيين كلمة المرور.',
          style: TextStyle(fontFamily: kFontFamily, fontSize: 14, color: kTextMedium, height: 1.5),
        ),

        SizedBox(height: 32),

        // ③ حقل الإيميل
        AppTextField(
          label: 'البريد الإلكتروني',
          hint: 'example@university.edu',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          controller: _emailController,
          validator: (v) => v!.isEmpty ? 'أدخل البريد الإلكتروني' : null,
        ),

        SizedBox(height: 24),

        // ④ زر إرسال OTP
        PrimaryButton(
          label: 'إرسال رمز التحقق',
          isLoading: _isLoading,
          onPressed: _sendOtp,
        ),

        SizedBox(height: 16),

        // ⑤ رسالة نجاح (تظهر بعد الإرسال)
        if (_sent)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.08),
              borderRadius: BorderRadius.circular(kRadiusSmall),
              border: Border.all(color: kSuccess.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(Icons.check_circle_outline, color: kSuccess, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('تم إرسال رمز التحقق، تحقق من بريدك.',
                style: TextStyle(color: kSuccess, fontFamily: kFontFamily, fontSize: 13),
              )),
            ]),
          ),

      ],
    ),
  ),
)
```

### المنطق
```dart
final _emailController = TextEditingController();
bool _isLoading = false;
bool _sent = false;
String? _errorMessage;

Future<void> _sendOtp() async {
  if (_emailController.text.trim().isEmpty) return;
  setState(() { _isLoading = true; _errorMessage = null; });

  try {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      _emailController.text.trim(),
      redirectTo: null, // بنستخدم OTP flow مش magic link
    );
    // أو لو بتستخدم OTP:
    // await Supabase.instance.client.auth.signInWithOtp(email: _emailController.text.trim());

    setState(() => _sent = true);

    // بعد ثانيتين روح لشاشة إدخال الـ OTP
    await Future.delayed(Duration(seconds: 2));
    if (mounted) context.go('/otp', extra: _emailController.text.trim());

  } on AuthException catch (e) {
    setState(() => _errorMessage = 'البريد غير مسجل في النظام');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## Screen 04 — OTPScreen

### الهدف
إدخال الـ OTP المرسل للإيميل للتحقق من الهوية.

### الـ UI Layout
```
Scaffold(
  backgroundColor: kScaffoldBg,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: BackButton(color: kPrimaryBlue),
  ),
  body: Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        SizedBox(height: 16),

        // ① أيقونة
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: kPrimaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined, color: kWhite, size: 40),
        ),

        SizedBox(height: 24),

        // ② عنوان
        Text('رمز التحقق',
          style: TextStyle(fontFamily: kFontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: kTextDark),
        ),
        SizedBox(height: 8),
        RichText(text: TextSpan(
          style: TextStyle(fontFamily: kFontFamily, fontSize: 14, color: kTextMedium),
          children: [
            TextSpan(text: 'أُرسل رمز مكوّن من 6 أرقام إلى '),
            TextSpan(text: email,
              style: TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        )),

        SizedBox(height: 40),

        // ③ حقول OTP (6 خانات)
        // استخدم package: pinput
        Pinput(
          length: 6,
          defaultPinTheme: PinTheme(
            width: 48, height: 56,
            textStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark,
            ),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(kRadiusMedium),
              border: Border.all(color: kDivider),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 48, height: 56,
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryBlue),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(kRadiusMedium),
              border: Border.all(color: kPrimaryBlue, width: 2),
            ),
          ),
          onCompleted: (pin) => _verifyOtp(pin),
          controller: _otpController,
        ),

        SizedBox(height: 32),

        // ④ زر التحقق
        PrimaryButton(
          label: 'تحقق',
          isLoading: _isLoading,
          onPressed: () => _verifyOtp(_otpController.text),
        ),

        SizedBox(height: 24),

        // ⑤ إعادة الإرسال مع countdown
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('لم تستلم الرمز؟ ', style: TextStyle(color: kTextMedium, fontFamily: kFontFamily)),
            _countdown > 0
              ? Text('إعادة الإرسال بعد $_countdown ثانية',
                  style: TextStyle(color: kTextLight, fontFamily: kFontFamily))
              : TextButton(
                  onPressed: _resendOtp,
                  child: Text('إعادة الإرسال',
                    style: TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.bold, fontFamily: kFontFamily),
                  ),
                ),
          ],
        ),

        // ⑥ رسالة خطأ
        if (_errorMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(_errorMessage!,
              style: TextStyle(color: kError, fontFamily: kFontFamily, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

      ],
    ),
  ),
)
```

### المنطق
```dart
final String email; // جاي من ForgotPasswordScreen عبر context.extra
final _otpController = TextEditingController();
bool _isLoading = false;
String? _errorMessage;
int _countdown = 60; // ثواني قبل إعادة الإرسال
Timer? _timer;

@override
void initState() {
  super.initState();
  _startCountdown();
}

void _startCountdown() {
  _timer = Timer.periodic(Duration(seconds: 1), (t) {
    if (_countdown == 0) { t.cancel(); return; }
    setState(() => _countdown--);
  });
}

Future<void> _verifyOtp(String token) async {
  if (token.length < 6) return;
  setState(() { _isLoading = true; _errorMessage = null; });

  try {
    final response = await Supabase.instance.client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery, // أو magiclink حسب الـ flow
    );

    if (response.user != null && mounted) {
      context.go('/reset-password', extra: response.session?.accessToken);
    }
  } on AuthException catch (e) {
    setState(() => _errorMessage = 'الرمز غير صحيح أو انتهت صلاحيته');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

Future<void> _resendOtp() async {
  setState(() => _countdown = 60);
  _startCountdown();
  await Supabase.instance.client.auth.resetPasswordForEmail(email);
}
```

### الحزمة المطلوبة
```yaml
# pubspec.yaml
dependencies:
  pinput: ^5.0.0
```

---

## Screen 05 — ResetPasswordScreen

### الهدف
إدخال كلمة المرور الجديدة بعد التحقق من الـ OTP.

### الـ UI Layout
```
Scaffold(
  backgroundColor: kScaffoldBg,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false, // مفيش رجوع — الـ session اتغير
    title: Text('كلمة مرور جديدة',
      style: TextStyle(color: kTextDark, fontFamily: kFontFamily, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  ),
  body: Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 16),

        // ① أيقونة
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: kPrimaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_open_outlined, color: kPrimaryTeal, size: 40),
          ),
        ),

        SizedBox(height: 24),

        Text('أنشئ كلمة مرور جديدة',
          style: TextStyle(fontFamily: kFontFamily, fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark),
        ),
        SizedBox(height: 8),
        Text('يجب أن تكون 8 أحرف على الأقل وتحتوي على أرقام وحروف.',
          style: TextStyle(fontFamily: kFontFamily, fontSize: 14, color: kTextMedium, height: 1.5),
        ),

        SizedBox(height: 32),

        // ② كلمة المرور الجديدة
        AppTextField(
          label: 'كلمة المرور الجديدة',
          hint: '••••••••',
          obscureText: _obscure1,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure1 = !_obscure1),
          ),
          controller: _pass1Controller,
          validator: (v) {
            if (v!.length < 8) return 'كلمة المرور قصيرة جداً';
            if (!v.contains(RegExp(r'[0-9]'))) return 'يجب أن تحتوي على أرقام';
            return null;
          },
        ),

        SizedBox(height: 16),

        // ③ تأكيد كلمة المرور
        AppTextField(
          label: 'تأكيد كلمة المرور',
          hint: '••••••••',
          obscureText: _obscure2,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure2 = !_obscure2),
          ),
          controller: _pass2Controller,
          validator: (v) => v != _pass1Controller.text ? 'كلمتا المرور غير متطابقتين' : null,
        ),

        SizedBox(height: 16),

        // ④ مؤشر قوة كلمة المرور
        PasswordStrengthIndicator(password: _pass1Controller.text),

        SizedBox(height: 32),

        // ⑤ زر الحفظ
        PrimaryButton(
          label: 'حفظ كلمة المرور',
          isLoading: _isLoading,
          onPressed: _handleReset,
        ),

      ],
    ),
  ),
)
```

### الـ PasswordStrengthIndicator Widget
```dart
// widget بسيط يعرض قوة كلمة المرور
// يحسب: قصيرة (أحمر) / متوسطة (برتقالي) / قوية (أخضر)
Widget PasswordStrengthIndicator({ required String password }) {
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
      Row(children: List.generate(4, (i) => Expanded(
        child: Container(
          height: 4, margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
          decoration: BoxDecoration(
            color: i < strength ? colors[strength] : kDivider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ))),
      if (password.isNotEmpty) ...[
        SizedBox(height: 4),
        Text('قوة كلمة المرور: ${labels[strength]}',
          style: TextStyle(color: colors[strength], fontSize: 12, fontFamily: kFontFamily),
        ),
      ],
    ],
  );
}
```

### المنطق
```dart
final _formKey = GlobalKey<FormState>();
final _pass1Controller = TextEditingController();
final _pass2Controller = TextEditingController();
bool _isLoading = false;
bool _obscure1 = true;
bool _obscure2 = true;

Future<void> _handleReset() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: _pass1Controller.text),
    );

    // عرض SnackBar نجاح ثم الانتقال للـ Login
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح ✓',
            style: TextStyle(fontFamily: kFontFamily),
          ),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await Future.delayed(Duration(seconds: 1));
      context.go('/login');
    }
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ أثناء تغيير كلمة المرور',
          style: TextStyle(fontFamily: kFontFamily),
        ),
        backgroundColor: kError,
      ),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 🗂️ هيكل الملفات المقترح للـ Auth

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       ← كل الألوان من الـ Design Tokens
│   │   ├── app_text_styles.dart  ← كل الـ TextStyles
│   │   └── app_theme.dart        ← ThemeData الكاملة
│   └── router/
│       └── app_router.dart       ← GoRouter مع كل الـ routes
│
├── shared/
│   └── widgets/
│       ├── app_text_field.dart   ← AppTextField الموحّد
│       ├── primary_button.dart   ← PrimaryButton الموحّد
│       └── password_strength.dart ← PasswordStrengthIndicator
│
└── features/
    └── auth/
        ├── screens/
        │   ├── splash_screen.dart
        │   ├── login_screen.dart
        │   ├── forgot_password_screen.dart
        │   ├── otp_screen.dart
        │   └── reset_password_screen.dart
        └── providers/
            └── auth_provider.dart  ← Riverpod/Provider للـ auth state
```

---

## 📦 الحزم المطلوبة

```yaml
dependencies:
  supabase_flutter: ^2.5.0   # Supabase Auth
  go_router: ^14.0.0          # Navigation
  pinput: ^5.0.0              # OTP input fields
  google_fonts: ^6.2.1        # Cairo font
  flutter_riverpod: ^2.5.1    # State management (أو provider حسب المشروع)
```

---

## 🔗 الـ Routes (GoRouter)

```dart
final router = GoRouter(routes: [
  GoRoute(path: '/',              builder: (_, __) => SplashScreen()),
  GoRoute(path: '/login',         builder: (_, __) => LoginScreen()),
  GoRoute(path: '/forgot-password', builder: (_, __) => ForgotPasswordScreen()),
  GoRoute(path: '/otp',           builder: (_, state) => OTPScreen(email: state.extra as String)),
  GoRoute(path: '/reset-password', builder: (_, __) => ResetPasswordScreen()),
  GoRoute(path: '/home',          builder: (_, __) => HomeScreen()),
]);
```
