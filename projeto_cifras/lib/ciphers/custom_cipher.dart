import 'package:projeto_cifras/ciphers/vigenere_cipher.dart';
import 'package:projeto_cifras/ciphers/rail_fence_cipher.dart';

class CustomCipher {
  
  final VigenereCipher _vigenere = VigenereCipher();
  final RailFenceCipher _railFence = RailFenceCipher();

  String encrypt(String text, String textKey, int numKey) {
    if (textKey.isEmpty) return "Erro: Chave de Vigenère não pode ser vazia.";
    if (numKey <= 1) return "Erro: Chave de Rail Fence deve ser > 1.";

    String vigenereResult = _vigenere.encrypt(text, textKey);

    String finalResult = _railFence.encrypt(vigenereResult, numKey);
    
    return finalResult;
  }

  String decrypt(String text, String textKey, int numKey) {
    if (textKey.isEmpty) return "Erro: Chave de Vigenère não pode ser vazia.";
    if (numKey <= 1) return "Erro: Chave de Rail Fence deve ser > 1.";

    String railFenceResult = _railFence.decrypt(text, numKey);

    String finalResult = _vigenere.decrypt(railFenceResult, textKey);
    
    return finalResult;
  }
}