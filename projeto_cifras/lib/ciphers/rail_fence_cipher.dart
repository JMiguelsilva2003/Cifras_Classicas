class RailFenceCipher {
  
  String encrypt(String text, int key) {
    if (key <= 1) return text;

    var rails = List.generate(key, (_) => <String>[]);
    
    int currentRail = 0;
    bool goingDown = true;

    for (int i = 0; i < text.length; i++) {
      rails[currentRail].add(text[i]);

      if (goingDown) {
        currentRail++;
        if (currentRail == key - 1) {
          goingDown = false;
        }
      } else {
        currentRail--;
        if (currentRail == 0) {
          goingDown = true;
        }
      }
    }

    String result = "";
    for (var rail in rails) {
      result += rail.join();
    }
    return result;
  }

  String decrypt(String text, int key) {
    if (key <= 1) return text;

    List<int> railLengths = List.filled(key, 0);
    int currentRail = 0;
    bool goingDown = true;

    for (int i = 0; i < text.length; i++) {
      railLengths[currentRail]++;

      if (goingDown) {
        currentRail++;
        if (currentRail == key - 1) goingDown = false;
      } else {
        currentRail--;
        if (currentRail == 0) goingDown = true;
      }
    }

    var rails = List.generate(key, (_) => <String>[]);
    int textIndex = 0;
    for (int i = 0; i < key; i++) {
      for (int j = 0; j < railLengths[i]; j++) {
        rails[i].add(text[textIndex++]);
      }
    }

    String result = "";
    currentRail = 0;
    goingDown = true;
    var railCounters = List.filled(key, 0);

    for (int i = 0; i < text.length; i++) {
      result += rails[currentRail][railCounters[currentRail]++];
      
      if (goingDown) {
        currentRail++;
        if (currentRail == key - 1) goingDown = false;
      } else {
        currentRail--;
        if (currentRail == 0) goingDown = true;
      }
    }
    
    return result;
  }
}