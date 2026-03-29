import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/register_screen.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static String get namedRoute => 'loginScreen';
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
                SizedBox(
                  height: 300,
                  child: Image.asset('assets/images/hamnava.png'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44.0,
                    vertical: 22.0,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      controller: _usernameController,
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
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        label: const Text('ایمیل'),
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
                    vertical: 22.0,
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
                          return 'لطفاً رمز عبور خود را وارد کنید';
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
                        label: const Text('رمز عبور'),
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
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      state.result.fold(
                        (failure) {
                          return ScaffoldMessenger.of(context).showSnackBar(
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
                        if (_formKey.currentState!.validate()) {
                          final username = _usernameController.text.trim();
                          final password = _passwordController.text.trim();

                          context.read<AuthBloc>().add(
                            AuthLoginEvent(username, password),
                          );
                        }
                      },
                      child: const Text(
                        'ورود به اکانت',
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
                    context.goNamed(RegisterScreen.namedRoute);
                  },
                  child: const Text(
                    'ساخت اکانت جدید',
                    style: TextStyle(
                      color: Color.fromARGB(185, 33, 149, 243),
                      fontFamily: 'CR',
                      fontSize: 12,
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
