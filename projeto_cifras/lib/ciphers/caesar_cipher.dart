class CaesarCipher {
  final String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  String encrypt(String text, int shift) {
    String result = "";
    String upperText = text.toUpperCase();

    for (int i = 0; i < upperText.length; i++) {
      String char = upperText[i];
      int charIndex = _alphabet.indexOf(char); 

      if (charIndex != -1) {
        int newIndex = (charIndex + shift) % _alphabet.length;

        if (newIndex < 0) {
          newIndex += _alphabet.length;
        }

        result += _alphabet[newIndex];
      } else {
        result += char;
      }
    }
    return result;
  }

  String decrypt(String text, int shift) {
    return encrypt(text, -shift);
  }
}