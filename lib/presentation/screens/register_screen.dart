import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  static String get namedRoute => 'RegisterScreen';
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  File? _selectedAvatar;

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 54,
                      child: _selectedAvatar == null
                          ? const Icon(
                              FontAwesomeIcons.user,
                              size: 48,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    Positioned(
                      left: 75,
                      top: 75,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(FontAwesomeIcons.pencil, size: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44.0,
                    vertical: 12.0,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      controller: _nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'لطفاً نام خود را وارد کنید';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromARGB(255, 14, 208, 211),
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),

                        label: const Text('نام'),

                        labelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),

                        floatingLabelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44.0,
                    vertical: 12.0,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      controller: _userNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'لطفاً نام کاربری را وارد کنید';
                        }
                        final englishRegex = RegExp(r'^[a-z0-9_]+$');
                        if (!englishRegex.hasMatch(value)) {
                          return 'فقط حروف انگلیسی کوچک، عدد و _ مجاز است';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromARGB(255, 14, 208, 211),
                          ),
                        ),
                        label: const Text('نام کاربری'),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),

                        labelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),

                        floatingLabelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),
                        prefixText: '@',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44.0,
                    vertical: 12.0,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      controller: _emailController,
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
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromARGB(255, 14, 208, 211),
                          ),
                        ),
                        label: const Text('ایمیل'),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),

                        labelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),

                        floatingLabelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44.0,
                    vertical: 12.0,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      obscureText: true,
                      controller: _passwordController,
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
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromARGB(255, 14, 208, 211),
                          ),
                        ),
                        label: const Text('رمز عبور'),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),

                        labelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),

                        floatingLabelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44.0,
                    vertical: 12.0,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      obscureText: true,
                      controller: _passwordConfirmController,
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
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromARGB(255, 14, 208, 211),
                          ),
                        ),
                        label: const Text('تکرار رمز عبور'),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),

                        labelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),

                        floatingLabelStyle: WidgetStateTextStyle.resolveWith((
                          Set<WidgetState> states,
                        ) {
                          Color labelColor = Colors.black;

                          if (states.contains(WidgetState.error)) {
                            labelColor = Colors.red;
                          } else if (states.contains(WidgetState.focused)) {
                            labelColor = const Color.fromARGB(
                              255,
                              14,
                              208,
                              211,
                            );
                          }

                          return TextStyle(fontFamily: 'CR', color: labelColor);
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      state.result.fold(
                        (failure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                textDirection: TextDirection.rtl,
                                failure.message,
                                style: const TextStyle(
                                  fontFamily: 'CR',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        (success) {
                          context.goNamed(HomeScreen.namedRoute);
                        },
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator(
                        color: Color.fromARGB(255, 14, 208, 211),
                      );
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color.fromARGB(
                          255,
                          14,
                          208,
                          211,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<AuthBloc>().add(
                            AuthRegisterEvent(
                              _nameController.text.trim(),
                              _userNameController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              _passwordConfirmController.text.trim(),
                              // _selectedAvatar,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'ساخت اکانت',
                        style: TextStyle(
                          fontFamily: 'CR',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    context.goNamed(LoginScreen.namedRoute);
                  },
                  child: const Text(
                    'ورود به اکانت',
                    style: TextStyle(
                      color: Color.fromARGB(185, 33, 149, 243),
                      fontFamily: 'CR',
                      fontSize: 15,
                    ),
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
