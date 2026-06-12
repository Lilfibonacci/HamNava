import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _urlController.text = locator.get<PocketBaseConfig>().currentUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _connectAndSaveServer() async {
    final targetUrl = _urlController.text.trim();
    if (targetUrl.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final pbConfig = locator.get<PocketBaseConfig>();
    final isServerAlive = await pbConfig.checkServerHealth(targetUrl);

    if (isServerAlive) {
      await pbConfig.updateServerUrl(targetUrl);
      await getItInit();
      if (mounted) context.goNamed(LoginScreen.namedRoute);
    } else {
      setState(() {
        _isLoading = false;
        _errorText =
            'امکان اتصال به این سرور وجود ندارد.\nپروتکل (http/https) یا پورت را بررسی کنید.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);

    final primaryColor = const Color(0xFF0ED0D3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,

        title: const Text(
          'تنظیمات سرور',
          style: TextStyle(fontFamily: 'CR', fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goNamed(LoginScreen.namedRoute),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.dns_rounded, size: 60, color: Color(0xFF0ED0D3)),
              const SizedBox(height: 24),
              const Text(
                'اتصال به سرور اختصاصی',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'CR',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _urlController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: 'http://192.168.1.50:8090',
                  errorText: _errorText,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _connectAndSaveServer,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text(
                          'تایید و اتصال',
                          style: TextStyle(fontFamily: 'CR', fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
