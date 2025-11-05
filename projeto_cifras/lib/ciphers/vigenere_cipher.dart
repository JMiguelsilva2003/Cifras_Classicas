class VigenereCipher {
  
  final String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  String _normalizeKey(String key) {
    return key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
  }

  String _process(String text, String key, int direction) {
    String normalizedKey = _normalizeKey(key);
    if (normalizedKey.isEmpty) {
      normalizedKey = 'A';
    }

    String upperText = text.toUpperCase();
    String result = "";
    int keyIndex = 0;

    for (int i = 0; i < upperText.length; i++) {
      String char = upperText[i];
      int charIndex = _alphabet.indexOf(char);

      if (charIndex != -1) {
        String keyChar = normalizedKey[keyIndex % normalizedKey.length];
        
        int shift = _alphabet.indexOf(keyChar);

        int newIndex = (charIndex + (shift * direction) + 26) % 26;

        result += _alphabet[newIndex];

        keyIndex++;
      } else {
        result += char;
      }
    }
    return result;
  }

  String encrypt(String text, String key) {
    return _process(text, key, 1);
  }

  String decrypt(String text, String key) {
    return _process(text, key, -1);
  }

  String? validateKey(String key) {
    String normalizedKey = _normalizeKey(key);
    if (normalizedKey.isEmpty) {
      return 'Erro: A chave deve conter pelo menos uma letra (A-Z).';
    }
    return null;
  }
}