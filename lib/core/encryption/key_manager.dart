import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'encryption_service.dart';

class KeyManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final EncryptionService _encryptionService;
  
  SimpleKeyPair? _myKeyPair;

  KeyManager(this._encryptionService);

  // Initialize key pair on app start or login
  Future<void> initialize(String userId) async {
    final privateKeyBase64 = await _storage.read(key: 'private_key_$userId');
    if (privateKeyBase64 != null) {
      _myKeyPair = await _encryptionService.importKeyPairFromBase64(privateKeyBase64);
    }
  }

  // Generate new keys and store private key securely
  // Returns the Public Key in base64 to send to the server
  Future<String> generateAndStoreKeys(String userId) async {
    _myKeyPair = await _encryptionService.generateKeyPair();
    final privateKeyBase64 = await _encryptionService.exportPrivateKeyBase64(_myKeyPair!);
    final publicKeyBase64 = await _encryptionService.exportPublicKeyBase64(_myKeyPair!);
    
    await _storage.write(key: 'private_key_$userId', value: privateKeyBase64);
    
    return publicKeyBase64;
  }

  // Get current key pair
  SimpleKeyPair? get myKeyPair => _myKeyPair;

  // Check if we have keys loaded
  bool hasKeys() => _myKeyPair != null;

  // Clear keys on logout
  Future<void> clearKeys(String userId) async {
    _myKeyPair = null;
    await _storage.delete(key: 'private_key_$userId');
  }
}
