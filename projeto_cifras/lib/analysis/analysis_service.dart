import 'package:flutter/foundation.dart';

class TextPair {
  final String original;
  final String ciphered;
  TextPair({required this.original, required this.ciphered});
}

class AnalysisService {
  AnalysisService._();
  static final AnalysisService instance = AnalysisService._();

  final textPair = ValueNotifier<TextPair>(
    TextPair(original: "", ciphered: ""),
  );

  void updateTexts(String original, String ciphered) {
    textPair.value = TextPair(original: original, ciphered: ciphered);
  }
}