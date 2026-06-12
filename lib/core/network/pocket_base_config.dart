import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PocketBaseConfig {
  final SharedPreferences _prefs;
  late PocketBase _pocketBase;

  static const String _defaultUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );

  PocketBaseConfig(this._prefs) {
    final savedUrl = _prefs.getString('custom_pb_url') ?? _defaultUrl;
    _initPocketBase(savedUrl);
  }

  PocketBase get client => _pocketBase;

  String get currentUrl => _prefs.getString('custom_pb_url') ?? _defaultUrl;

  void _initPocketBase(String url) {
    final store = AsyncAuthStore(
      initial: _prefs.getString('pb_auth'),
      save: (String data) async => await _prefs.setString('pb_auth', data),
      clear: () async => await _prefs.remove('pb_auth'),
    );
    _pocketBase = PocketBase(url, authStore: store);
  }

  Future<void> updateServerUrl(String newUrl) async {
    _pocketBase.authStore.clear();
    await _prefs.setString('custom_pb_url', newUrl);
    _initPocketBase(newUrl);
  }

  Future<bool> checkServerHealth(String url) async {
    try {
      final cleanUrl = url.endsWith('/') ? url : '$url/';
      final response = await http
          .get(Uri.parse('${cleanUrl}api/health'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
