import 'dart:convert';
import 'dart:typed_data';

class VernamCipher {

  Uint8List _processXOR(Uint8List textBytes, Uint8List keyBytes) {
    Uint8List resultBytes = Uint8List(textBytes.length);

    for (int i = 0; i < textBytes.length; i++) {
      int textByte = textBytes[i];
      
      int keyByte = keyBytes[i % keyBytes.length];

      resultBytes[i] = textByte ^ keyByte;
    }
    return resultBytes;
  }

  String encrypt(String text, String key) {
    Uint8List textBytes = utf8.encode(text);
    Uint8List keyBytes = utf8.encode(key);

    Uint8List encryptedBytes = _processXOR(textBytes, keyBytes);

    return base64.encode(encryptedBytes);
  }

  String decrypt(String base64Text, String key) {
    try {
      Uint8List encryptedBytes = base64.decode(base64Text);
      
      Uint8List keyBytes = utf8.encode(key);

      Uint8List decryptedBytes = _processXOR(encryptedBytes, keyBytes);

      return utf8.decode(decryptedBytes);
    } catch (e) {
      return 'Erro: O texto a ser decifrado não é um Base64 válido.';
    }
  }

  String? validateKey(String key) {
    if (key.isEmpty) {
      return 'Erro: A chave não pode estar vazia.';
    }
    return null;
  }
}