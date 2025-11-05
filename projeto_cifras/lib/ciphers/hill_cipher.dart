import 'package:scidart/numdart.dart';

class HillCipher {
  final String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  Array2d _createKeyMatrix(String key, int m) {
    String upperKey = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    var matrix = Array2d(List.generate(m, (_) => Array.fixed(m)));
    int k = 0;

    for (int i = 0; i < m; i++) {
      for (int j = 0; j < m; j++) {
        if (k < upperKey.length) {
          matrix[i][j] = _alphabet.indexOf(upperKey[k]).toDouble();
          k++;
        } else {
          matrix[i][j] = 0.0;
        }
      }
    }
    return matrix;
  }

  Array2d _createTextVector(String textBlock, int m) {
    var vector = Array2d(List.generate(m, (_) => Array.fixed(1)));
    
    for (int i = 0; i < m; i++) {
      if (i < textBlock.length) {
        vector[i][0] = _alphabet.indexOf(textBlock[i]).toDouble();
      } else {
        vector[i][0] = 23.0; // 'X'
      }
    }
    return vector;
  }

  String _vectorToText(Array2d vector) {
    String text = "";
    for (int i = 0; i < vector.row; i++) {
      var val = vector[i][0];
      int charCode = (val.round() % 26 + 26) % 26;
      text += _alphabet[charCode];
    }
    return text;
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  String? validateKey(String key, int m) {
    if (m < 2) {
      return 'Erro: O tamanho do bloco (m) deve ser >= 2.';
    }
    if (key.length < m * m) {
      return 'Erro: A chave deve ter pelo menos $m x $m = ${m * m} letras.';
    }

    var keyMatrix = _createKeyMatrix(key, m);
    int det = (matrixDeterminant(keyMatrix).round() % 26 + 26) % 26;

    if (_gcd(det, 26) != 1) {
      return 'Erro: Chave inválida. O determinante ($det) não é coprimo de 26. Tente outra chave.';
    }

    return null;
  }

  String encrypt(String text, String key, int m) {
    var keyMatrix = _createKeyMatrix(key, m);
    String upperText = text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    String result = "";

    for (int i = 0; i < upperText.length; i += m) {
      String block = upperText.substring(
          i, i + m > upperText.length ? upperText.length : i + m);
      
      var textVector = _createTextVector(block, m); 
      var resultVector = matrixDot(keyMatrix, textVector);
      result += _vectorToText(resultVector);
    }
    return result;
  }

  Array2d _findModularInverse(Array2d keyMatrix, int m) {

    int det = (matrixDeterminant(keyMatrix).round() % 26 + 26) % 26;

    int detInv = det.modInverse(26);

    var invMatrix = matrixInverse(keyMatrix);
    
    var detNormal = matrixDeterminant(keyMatrix);
    
    var adjMatrix = Array2d(List.generate(m, (_) => Array.fixed(m)));
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < m; j++) {
        adjMatrix[i][j] = invMatrix[i][j] * detNormal;
      }
    }
    
    var modInverseMatrix = Array2d(List.generate(m, (_) => Array.fixed(m)));
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < m; j++) {
        int val = adjMatrix[i][j].round();
        int modVal = ((val * detInv) % 26 + 26) % 26;
        modInverseMatrix[i][j] = modVal.toDouble();
      }
    }
    return modInverseMatrix;
  }

  String decrypt(String text, String key, int m) {
    var keyMatrix = _createKeyMatrix(key, m);
    var inverseMatrix = _findModularInverse(keyMatrix, m);
    
    String upperText = text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    String result = "";

    for (int i = 0; i < upperText.length; i += m) {
      String block = upperText.substring(
          i, i + m > upperText.length ? upperText.length : i + m);
      
      var textVector = _createTextVector(block, m);
      var resultVector = matrixDot(inverseMatrix, textVector);
      result += _vectorToText(resultVector);
    }
    return result;
  }
}