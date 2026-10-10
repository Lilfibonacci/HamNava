import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  static String get routeName => 'loadingScreen';

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final isAuthenticated = locator
            .get<PocketBaseConfig>()
            .client
            .authStore
            .isValid;

        if (isAuthenticated) {
          context.goNamed(HomeScreen.namedRoute);
        } else {
          context.goNamed(LoginScreen.namedRoute);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Responsive breakpoints
    double lottieWidth;
    double lottieHeight;

    if (screenWidth < 600) {
      // Mobile
      lottieWidth = screenWidth * 0.65;
      lottieHeight = size.height * 0.3;
    } else if (screenWidth < 1024) {
      // Tablet
      lottieWidth = screenWidth * 0.45;
      lottieHeight = size.height * 0.35;
    } else {
      // Desktop
      lottieWidth = screenWidth * 0.25;
      lottieHeight = size.height * 0.4;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/WaterSplash.json',
              width: lottieWidth,
              height: lottieHeight,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
