// file: lib/features/profile/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  const EditProfileScreen({super.key, required this.name, required this.email});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _phoneController = TextEditingController(text: '01012345678');

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(seconds: 1500));

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث الملف الشخصي بنجاح',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: kSuccess,
        ),
      );

      // Return the updated data
      Navigator.of(context).pop({
        'name': _nameController.text,
        'email': _emailController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: kDarkNavy,
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تعديل الملف الشخصي',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Section Title
                Text(
                  'معلومات الحساب الأساسية',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 16),

                // Name input
                Text(
                  'الاسم بالكامل *',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(color: kTextDark),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الاسم مطلوب';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email input
                Text(
                  'البريد الإلكتروني *',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(color: kTextDark),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone input
                Text(
                  'رقم الهاتف',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.cairo(color: kTextDark),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 48),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: kWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kWhite))
                        : Text('حفظ التغييرات', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
