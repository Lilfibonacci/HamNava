import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class EncryptionService {
  final X25519 _keyAgreement = X25519();
  final AesGcm _aesGcm = AesGcm.with256bits();

  // Generate a new X25519 KeyPair
  Future<SimpleKeyPair> generateKeyPair() async {
    return await _keyAgreement.newKeyPair();
  }

  // Export public key to base64 string (for storing in PocketBase)
  Future<String> exportPublicKeyBase64(SimpleKeyPair keyPair) async {
    final publicKey = await keyPair.extractPublicKey();
    return base64Encode(publicKey.bytes);
  }

  // Export private key to base64 string (for secure storage)
  Future<String> exportPrivateKeyBase64(SimpleKeyPair keyPair) async {
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    return base64Encode(privateKeyBytes);
  }

  // Reconstruct KeyPair from private key base64 string
  Future<SimpleKeyPair> importKeyPairFromBase64(String privateKeyBase64) async {
    final privateKeyBytes = base64Decode(privateKeyBase64);
    return await _keyAgreement.newKeyPairFromSeed(privateKeyBytes);
  }

  // Derive shared secret between my private key and other's public key
  Future<SecretKey> deriveSharedSecret(SimpleKeyPair myKeyPair, String otherPublicKeyBase64) async {
    final otherPublicKeyBytes = base64Decode(otherPublicKeyBase64);
    final otherPublicKey = SimplePublicKey(otherPublicKeyBytes, type: KeyPairType.x25519);
    
    final sharedSecret = await _keyAgreement.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: otherPublicKey,
    );
    return sharedSecret;
  }

  // Encrypt string message using shared secret
  Future<String> encryptText(String plainText, SecretKey sharedSecret) async {
    final messageBytes = utf8.encode(plainText);
    final secretBox = await _aesGcm.encrypt(
      messageBytes,
      secretKey: sharedSecret,
    );
    
    // Combine nonce (12 bytes) + mac (16 bytes) + cipherText
    final combined = [...secretBox.nonce, ...secretBox.mac.bytes, ...secretBox.cipherText];
    return base64Encode(combined);
  }

  // Decrypt string message using shared secret
  Future<String> decryptText(String encryptedBase64, SecretKey sharedSecret) async {
    try {
      final combined = base64Decode(encryptedBase64);
      
      // AES-GCM nonce is 12 bytes, MAC is 16 bytes = 28 bytes minimum
      if (combined.length < 28) {
        return encryptedBase64; // Return as is (might be old unencrypted message)
      }

      final nonce = combined.sublist(0, 12);
      final macBytes = combined.sublist(12, 28);
      final cipherText = combined.sublist(28);

      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final decryptedBytes = await _aesGcm.decrypt(
        secretBox,
        secretKey: sharedSecret,
      );
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      // If decryption fails (e.g. wrong key, or wasn't encrypted), return original text
      return encryptedBase64; 
    }
  }

  // Generate a random SecretKey (MessageKey)
  Future<SecretKey> generateRandomSymmetricKey() async {
    return await _aesGcm.newSecretKey();
  }

  // Encrypt the MessageKey with the DH Shared Secret
  Future<String> encryptSymmetricKey(SecretKey messageKey, SecretKey sharedSecret) async {
    final messageKeyBytes = await messageKey.extractBytes();
    final secretBox = await _aesGcm.encrypt(
      messageKeyBytes,
      secretKey: sharedSecret,
    );
    final combined = [...secretBox.nonce, ...secretBox.mac.bytes, ...secretBox.cipherText];
    return base64Encode(combined);
  }

  // Decrypt the MessageKey with the DH Shared Secret
  Future<SecretKey?> decryptSymmetricKey(String encryptedBase64, SecretKey sharedSecret) async {
    try {
      final combined = base64Decode(encryptedBase64);
      if (combined.length < 28) return null;

      final nonce = combined.sublist(0, 12);
      final macBytes = combined.sublist(12, 28);
      final cipherText = combined.sublist(28);

      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final decryptedBytes = await _aesGcm.decrypt(
        secretBox,
        secretKey: sharedSecret,
      );
      
      return SecretKey(decryptedBytes);
    } catch (e) {
      return null;
    }
  }

  // Encrypt binary data (files/media) using shared secret

  Future<List<int>> encryptBytes(List<int> data, SecretKey sharedSecret) async {
    final secretBox = await _aesGcm.encrypt(
      data,
      secretKey: sharedSecret,
    );
    return [...secretBox.nonce, ...secretBox.mac.bytes, ...secretBox.cipherText];
  }

  // Decrypt binary data (files/media) using shared secret
  Future<List<int>> decryptBytes(List<int> encryptedData, SecretKey sharedSecret) async {
    if (encryptedData.length < 28) return encryptedData;

    final nonce = encryptedData.sublist(0, 12);
    final macBytes = encryptedData.sublist(12, 28);
    final cipherText = encryptedData.sublist(28);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    return await _aesGcm.decrypt(
      secretBox,
      secretKey: sharedSecret,
    );
  }
}
