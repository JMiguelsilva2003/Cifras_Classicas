class FrequencyAnalyzer {

  Map<String, double> calculate(String text) {
    Map<String, int> counts = {};
    int totalLetters = 0;

    for (int i = 0; i < 26; i++) {
      counts[String.fromCharCode(i + 65)] = 0;
    }

    String upperText = text.toUpperCase();

    for (int i = 0; i < upperText.length; i++) {
      String char = upperText[i];
      if (counts.containsKey(char)) {
        counts[char] = counts[char]! + 1;
        totalLetters++;
      }
    }

    Map<String, double> percentages = {};
    if (totalLetters == 0) {
      counts.forEach((key, value) {
        percentages[key] = 0.0;
      });
    } else {
      counts.forEach((key, value) {
        percentages[key] = (value / totalLetters) * 100;
      });
    }

    return percentages;
  }
}