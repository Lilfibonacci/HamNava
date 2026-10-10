import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/constants/color.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:lottie/lottie.dart' as lottie;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  static String get namedRoute => 'RegisterScreen';
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ─── Form Keys ─────────────────────────────────────────────────────────
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();

  // ─── Controllers ──────────────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  // ─── State ─────────────────────────────────────────────────────────────
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  File? _selectedAvatar;

  // ─── PageView ──────────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalSteps = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Navigation ────────────────────────────────────────────────────────
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ─── Avatar picker ─────────────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedAvatar = File(result.files.single.path!);
      });
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_right, color: primaryColor),
          onPressed: () {
            if (_currentPage == 0) {
              context.goNamed(LoginScreen.namedRoute);
            } else {
              _prevPage();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // ─── Step Indicator ────────────────────────────────────────────
          _StepIndicator(
            currentStep: _currentPage,
            totalSteps: _totalSteps,
            activeColor: primaryColor,
            inactiveColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
          const SizedBox(height: 4),

          // ─── PageView ──────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                // اسلاید ۱ – نام و نام کاربری
                _buildStep1(
                  isDark: isDark,
                  size: size,
                  cardColor: cardColor,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  hintColor: hintColor,
                ),
                // اسلاید ۲ – اطلاعات ورود
                _buildStep2(
                  isDark: isDark,
                  size: size,
                  cardColor: cardColor,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  hintColor: hintColor,
                ),
                // اسلاید ۳ – انتخاب عکس پروفایل
                _buildStep3(
                  isDark: isDark,
                  size: size,
                  cardColor: cardColor,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  hintColor: hintColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // اسلاید ۱ – نام و نام کاربری
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildStep1({
    required bool isDark,
    required Size size,
    required Color cardColor,
    required Color primaryColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _step1FormKey,
            child: Column(
              children: [
                lottie.Lottie.asset(
                  'assets/loginanimation.json',
                  height: size.height * 0.25,
                  width: size.height * 0.25,
                ),
                const SizedBox(height: 8),
                Text(
                  'اطلاعات شخصی',
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'نام و نام کاربری خود را وارد کنید',
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 14,
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 32),

                // نام و نام خانوادگی
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      fontFamily: 'CR',
                      color: textColor,
                      fontSize: 16,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً نام خود را وارد کنید';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      isDark: isDark,
                      hint: 'نام و نام خانوادگی',
                      icon: CupertinoIcons.person,
                      cardColor: cardColor,
                      primaryColor: primaryColor,
                      hintColor: hintColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // نام کاربری
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _userNameController,
                    style: TextStyle(
                      fontFamily: 'CR',
                      color: textColor,
                      fontSize: 16,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً نام کاربری را وارد کنید';
                      }
                      final englishRegex =
                          RegExp(r'^[a-z0-9_]+$').hasMatch(value);
                      if (!englishRegex) {
                        return 'فقط حروف انگلیسی کوچک، عدد و _ مجاز است';
                      }
                      if (value.length <= 3) {
                        return 'نام کاربری باید بیشتر از سه حرف داشته باشد';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      isDark: isDark,
                      hint: 'نام کاربری',
                      icon: CupertinoIcons.at,
                      cardColor: cardColor,
                      primaryColor: primaryColor,
                      hintColor: hintColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // دکمه مرحله بعد
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_step1FormKey.currentState!.validate()) {
                        _nextPage();
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مرحله بعد',
                          style: TextStyle(
                            fontFamily: 'CR',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(CupertinoIcons.chevron_left, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // لینک لاگین
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'از قبل حساب دارید؟',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 14,
                        color: hintColor,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => context.goNamed(LoginScreen.namedRoute),
                      child: const Text(
                        'وارد شوید',
                        style: TextStyle(
                          fontFamily: 'CR',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // اسلاید ۲ – ایمیل، رمز عبور و تکرار
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildStep2({
    required bool isDark,
    required Size size,
    required Color cardColor,
    required Color primaryColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _step2FormKey,
            child: Column(
              children: [
                lottie.Lottie.asset(
                  'assets/loginanimation.json',
                  height: size.height * 0.25,
                  width: size.height * 0.25,
                ),
                const SizedBox(height: 8),
                Text(
                  'اطلاعات ورود',
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ایمیل و رمز عبور خود را تنظیم کنید',
                  style: TextStyle(
                    fontFamily: 'CR',
                    fontSize: 14,
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 32),

                // ایمیل
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _emailController,
                    style: TextStyle(
                      fontFamily: 'CR',
                      color: textColor,
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً ایمیل خود را وارد کنید';
                      }
                      final bool isEmailValid = RegExp(
                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                      ).hasMatch(value);
                      if (!isEmailValid) {
                        return 'لطفاً یک ایمیل معتبر وارد کنید';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      isDark: isDark,
                      hint: 'ایمیل',
                      icon: CupertinoIcons.mail,
                      cardColor: cardColor,
                      primaryColor: primaryColor,
                      hintColor: hintColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // رمز عبور
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    style: TextStyle(
                      fontFamily: 'CR',
                      color: textColor,
                      fontSize: 16,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً رمز عبور را وارد کنید';
                      }
                      if (value.length < 8) {
                        return 'رمز عبور باید حداقل ۸ کاراکتر باشد';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      isDark: isDark,
                      hint: 'رمز عبور',
                      icon: CupertinoIcons.lock,
                      cardColor: cardColor,
                      primaryColor: primaryColor,
                      hintColor: hintColor,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          color: hintColor,
                        ),
                        onPressed: () => setState(
                            () => _isPasswordObscured = !_isPasswordObscured),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // تکرار رمز عبور
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _passwordConfirmController,
                    obscureText: _isConfirmPasswordObscured,
                    style: TextStyle(
                      fontFamily: 'CR',
                      color: textColor,
                      fontSize: 16,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'لطفاً تکرار رمز عبور را وارد کنید';
                      }
                      if (value != _passwordController.text) {
                        return 'رمز عبور و تکرار آن مطابقت ندارند';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      isDark: isDark,
                      hint: 'تکرار رمز عبور',
                      icon: CupertinoIcons.lock_shield,
                      cardColor: cardColor,
                      primaryColor: primaryColor,
                      hintColor: hintColor,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscured
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          color: hintColor,
                        ),
                        onPressed: () => setState(() =>
                            _isConfirmPasswordObscured =
                                !_isConfirmPasswordObscured),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // دکمه مرحله بعد
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_step2FormKey.currentState!.validate()) {
                        _nextPage();
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مرحله بعد',
                          style: TextStyle(
                            fontFamily: 'CR',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(CupertinoIcons.chevron_left, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // اسلاید ۳ – انتخاب عکس پروفایل
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildStep3({
    required bool isDark,
    required Size size,
    required Color cardColor,
    required Color primaryColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'عکس پروفایل',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'یک عکس برای پروفایل خود انتخاب کنید',
              style: TextStyle(
                fontFamily: 'CR',
                fontSize: 14,
                color: hintColor,
              ),
            ),

            // فضای کشسان برای وسط‌چینی عمودی
            const Spacer(),

            // آواتار بزرگ با حالت انتخاب‌شده / نشده
            GestureDetector(
              onTap: _pickAvatar,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size.width * 0.5,
                height: size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor,
                  border: Border.all(
                    color: _selectedAvatar != null
                        ? primaryColor
                        : (isDark ? Colors.white12 : Colors.black12),
                    width: _selectedAvatar != null ? 3 : 2,
                  ),
                  boxShadow: _selectedAvatar != null
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ]
                      : [],
                ),
                child: ClipOval(
                  child: _selectedAvatar != null
                      ? Image.file(
                          _selectedAvatar!,
                          fit: BoxFit.cover,
                          width: size.width * 0.5,
                          height: size.width * 0.5,
                        )
                      : Icon(
                          CupertinoIcons.person_fill,
                          size: size.width * 0.22,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // دکمه انتخاب / تغییر عکس
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              onPressed: _pickAvatar,
              icon: Icon(
                _selectedAvatar != null
                    ? CupertinoIcons.arrow_2_circlepath
                    : CupertinoIcons.camera,
                size: 20,
              ),
              label: Text(
                _selectedAvatar != null ? 'تغییر عکس' : 'انتخاب عکس',
                style: const TextStyle(
                  fontFamily: 'CR',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            // دکمه «ساخت حساب» – لاجیک BLoC دست‌نخورده
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  state.result.fold(
                    (failure) {
                      final snackBar = buildCustomSnackBar(
                        title: 'failure',
                        message: failure.message,
                        color: CustomColor.red,
                        type: ContentType.failure,
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    },
                    (success) {
                      context.goNamed(HomeScreen.namedRoute);
                    },
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 14,
                        color: primaryColor,
                      ),
                    ),
                  );
                }
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            AuthRegisterEvent(
                              _nameController.text.trim(),
                              _userNameController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              _passwordConfirmController.text.trim(),
                            ),
                          );
                    },
                    child: const Text(
                      'ساخت حساب',
                      style: TextStyle(
                        fontFamily: 'CR',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // دکمه رد کردن (skip) – اختیاری
            TextButton(
              style: TextButton.styleFrom(foregroundColor: hintColor),
              onPressed: () {
                // بدون عکس مستقیم ثبت‌نام می‌کند
                context.read<AuthBloc>().add(
                      AuthRegisterEvent(
                        _nameController.text.trim(),
                        _userNameController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _passwordConfirmController.text.trim(),
                      ),
                    );
              },
              child: const Text(
                'رد کردن',
                style: TextStyle(
                  fontFamily: 'CR',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── InputDecoration helper ───────────────────────────────────────────
  InputDecoration _buildInputDecoration({
    required bool isDark,
    required String hint,
    required IconData icon,
    required Color cardColor,
    required Color primaryColor,
    required Color hintColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: cardColor,
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'CR', color: hintColor, fontSize: 15),
      prefixIcon: Icon(icon, color: hintColor, size: 22),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : Colors.black.withValues(alpha: .05),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// ویجت نشانگر مرحله (Step Indicator)
// ──────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isDone = index < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: (isActive || isDone) ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

