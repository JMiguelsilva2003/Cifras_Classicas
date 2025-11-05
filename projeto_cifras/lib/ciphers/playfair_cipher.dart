class PlayfairCipher {
  
  List<List<String>> _matrix = [];
  
  final String _alphabet = 'ABCDEFGHIKLMNOPQRSTUVWXYZ';

  String _normalizeText(String text) {
    return text
        .toUpperCase()
        .replaceAll('J', 'I') 
        .replaceAll(RegExp(r'[^A-Z]'), ''); 
  }

  void _generateMatrix(String key) {
    String normalizedKey = _normalizeText(key);
    String keyChars = ''; 
    Set<String> addedChars = {}; 

    for (var char in normalizedKey.split('')) {
      if (addedChars.add(char)) {
        keyChars += char;
      }
    }

    for (var char in _alphabet.split('')) {
      if (addedChars.add(char)) {
        keyChars += char;
      }
    }

    _matrix = List.generate(5, (_) => List.filled(5, ''));
    int index = 0;
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        _matrix[i][j] = keyChars[index++];
      }
    }
  }

  List<String> _prepareText(String text) {
    String normalized = _normalizeText(text);
    List<String> digraphs = [];
    int i = 0;

    while (i < normalized.length) {
      String char1 = normalized[i];
      String char2;

      if (i + 1 == normalized.length || normalized[i] == normalized[i + 1]) {
        char2 = 'X';
        i++;
      } else {
        char2 = normalized[i + 1];
        i += 2;
      }
      digraphs.add('$char1$char2');
    }
    return digraphs;
  }

  Map<String, int> _findPosition(String char) {
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        if (_matrix[i][j] == char) {
          return {'row': i, 'col': j};
        }
      }
    }
    return {'row': -1, 'col': -1};
  }

  String _processDigraph(String digraph, int direction) {
    String char1 = digraph[0];
    String char2 = digraph[1];

    Map<String, int> pos1 = _findPosition(char1);
    Map<String, int> pos2 = _findPosition(char2);

    int row1 = pos1['row']!;
    int col1 = pos1['col']!;
    int row2 = pos2['row']!;
    int col2 = pos2['col']!;

    String newChar1, newChar2;

    if (row1 == row2) {
      newChar1 = _matrix[row1][(col1 + direction + 5) % 5];
      newChar2 = _matrix[row2][(col2 + direction + 5) % 5];
    }
    else if (col1 == col2) {
      newChar1 = _matrix[(row1 + direction + 5) % 5][col1];
      newChar2 = _matrix[(row2 + direction + 5) % 5][col2];
    }
    else {
      newChar1 = _matrix[row1][col2];
      newChar2 = _matrix[row2][col1];
    }

    return '$newChar1$newChar2';
  }

  String encrypt(String text, String key) {
    _generateMatrix(key);
    List<String> digraphs = _prepareText(text);
    String result = "";

    for (var digraph in digraphs) {
      result += _processDigraph(digraph, 1);
    }
    return result;
  }

  String decrypt(String text, String key) {
    _generateMatrix(key);
    String normalizedText = _normalizeText(text);
    String result = "";

    for (int i = 0; i < normalizedText.length; i += 2) {
      String digraph = normalizedText.substring(i, i + 2);
      result += _processDigraph(digraph, -1);
    }
    
    return result;
  }
}