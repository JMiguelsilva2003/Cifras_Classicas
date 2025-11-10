class ColumnarTranspositionCipher {
  List<int> _getKeyOrder(String key) {
    String upperKey = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    List<MapEntry<String, int>> pairs = [];
    for (int i = 0; i < upperKey.length; i++) {
      pairs.add(MapEntry(upperKey[i], i));
    }
    pairs.sort((a, b) => a.key.compareTo(b.key));
    return pairs.map((e) => e.value).toList();
  }

  String encrypt(String text, String key) {
    if (key.isEmpty) return text;
    String normalizedKey = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    List<int> keyOrder = _getKeyOrder(normalizedKey);
    int numCols = normalizedKey.length;
    int numRows = (text.length / numCols).ceil();

    var grid = List.generate(numRows, (_) => List.filled(numCols, 'X'));
    int textIndex = 0;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        if (textIndex < text.length) {
          grid[i][j] = text[textIndex++];
        }
      }
    }

    String result = "";
    for (int colIndex in keyOrder) {
      for (int i = 0; i < numRows; i++) {
        result += grid[i][colIndex];
      }
    }
    return result;
  }

  String decrypt(String text, String key) {
    if (key.isEmpty) return text;
    String normalizedKey = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    List<int> keyOrder = _getKeyOrder(normalizedKey);
    int numCols = normalizedKey.length;
    int numRows = (text.length / numCols).ceil();

    var grid = List.generate(numRows, (_) => List.filled(numCols, ''));

    int textIndex = 0;
    for (int colIndex in keyOrder) {
      for (int i = 0; i < numRows; i++) {
        if (textIndex < text.length) {
          grid[i][colIndex] = text[textIndex++];
        }
      }
    }

    String result = "";
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        result += grid[i][j];
      }
    }

    return result.replaceAll(RegExp(r'X+$'), '');
  }
}
