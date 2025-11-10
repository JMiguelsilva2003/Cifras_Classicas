import 'dart:collection';

class MonoalphabeticCipher {
  
  final String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  String? validateKey(String key) {
    String upperKey = key.toUpperCase();
    if (upperKey.length != 26) return 'Erro: A chave deve ter exatamente 26 letras.';
    final Set<String> uniqueChars = HashSet<String>();
    for (int i = 0; i < upperKey.length; i++) {
      String char = upperKey[i];
      if (!_alphabet.contains(char)) return 'Erro: A chave só pode conter letras do alfabeto.';
      if (!uniqueChars.add(char)) return 'Erro: A chave contém letras repetidas (ex: $char).';
    }
    return null;
  }

  String encrypt(String text, String key) {
    String upperKey = key.toUpperCase();
    String upperText = text.toUpperCase();
    String result = "";

    for (int i = 0; i < upperText.length; i++) {
      String char = upperText[i];
      int charIndex = _alphabet.indexOf(char); 

      if (charIndex != -1) { 
        result += upperKey[charIndex];
      } else {
        result += char;
      }
    }
    return result;
  }

  String decrypt(String text, String key) {
    String upperKey = key.toUpperCase();
    String upperText = text.toUpperCase();
    String result = "";

    for (int i = 0; i < upperText.length; i++) {
      String char = upperText[i];
      int charIndex = upperKey.indexOf(char); 

      if (charIndex != -1) {
        result += _alphabet[charIndex];
      } else {
        result += char;
      }
    }
    return result;
  }
}