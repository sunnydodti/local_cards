import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart' as crypto;

class TransferService {
  // Encrypt a JSON-serializable payload with a password.
  // Returns a compact Base64 string suitable for embedding in a QR.
  static String encryptPayload(Map<String, dynamic> payload, String password) {
    final jsonText = jsonEncode(payload);
    final keyBytes = _deriveKey(password);
    final key = Key(Uint8List.fromList(keyBytes));
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonText, iv: iv);

    final wrapper = {
      'v': 1,
      'enc': true,
      'iv': base64Encode(iv.bytes),
      'data': base64Encode(encrypted.bytes),
    };
    final wrapperJson = jsonEncode(wrapper);
    return base64Encode(utf8.encode(wrapperJson));
  }

  // Decrypt a Base64-encoded wrapper string using the password.
  // Throws on invalid or wrong password.
  static Map<String, dynamic> decryptPayload(String encoded, String password) {
    final decoded = utf8.decode(base64Decode(encoded));
    final Map<String, dynamic> wrapper = jsonDecode(decoded);
    if (wrapper['enc'] != true) {
      throw Exception('Data is not encrypted');
    }
    final ivBytes = base64Decode(wrapper['iv'] as String);
    final dataBytes = base64Decode(wrapper['data'] as String);

    final keyBytes = _deriveKey(password);
    final key = Key(Uint8List.fromList(keyBytes));
    final iv = IV(Uint8List.fromList(ivBytes));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = Encrypted(Uint8List.fromList(dataBytes));
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    final Map<String, dynamic> payload = jsonDecode(decrypted);
    return payload;
  }

  static List<int> _deriveKey(String password) {
    final bytes = utf8.encode(password);
    final hash = crypto.sha256.convert(bytes);
    return hash.bytes;
  }
}
