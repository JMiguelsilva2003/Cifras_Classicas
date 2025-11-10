import 'columnar_transposition_cipher.dart';

class DoubleTranspositionCipher {
  
  final ColumnarTranspositionCipher _columnar = ColumnarTranspositionCipher();

  String encrypt(String text, String key1, String key2) {
    String firstPass = _columnar.encrypt(text, key1);
    String secondPass = _columnar.encrypt(firstPass, key2);
    return secondPass;
  }

  String decrypt(String text, String key1, String key2) {
    String firstPass = _columnar.decrypt(text, key2);
    String secondPass = _columnar.decrypt(firstPass, key1);
    return secondPass;
  }
}