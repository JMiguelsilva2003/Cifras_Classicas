import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:projeto_cifras/analysis/analysis_service.dart';
import 'package:projeto_cifras/ciphers/caesar_cipher.dart';
import 'package:projeto_cifras/ciphers/monoalphabetic_cipher.dart';
import 'package:projeto_cifras/ciphers/playfair_cipher.dart';
import 'package:projeto_cifras/ciphers/hill_cipher.dart';
import 'package:projeto_cifras/ciphers/vigenere_cipher.dart';
import 'package:projeto_cifras/ciphers/vernam_cipher.dart';
import 'package:projeto_cifras/ciphers/one_time_pad_cipher.dart';
import 'package:projeto_cifras/ciphers/rail_fence_cipher.dart';
import 'package:projeto_cifras/ciphers/columnar_transposition_cipher.dart';
import 'package:projeto_cifras/ciphers/double_transposition_cipher.dart';
import 'package:projeto_cifras/ciphers/custom_cipher.dart';

enum CipherType {
  caesar, monoalphabetic, playfair, hill, vigenere, vernam,
  oneTimePad, railFence, columnar, doubleTransposition, custom,
}
const Map<CipherType, String> cipherNames = {
  CipherType.caesar: '1. Cifra de César',
  CipherType.monoalphabetic: '2. Cifra Monoalfabética',
  CipherType.playfair: '3. Cifra de Playfair',
  CipherType.hill: '4. Cifra de Hill (m>=2)',
  CipherType.vigenere: '5. Cifra de Vigenère',
  CipherType.vernam: '6. Cifra de Vernam (XOR)',
  CipherType.oneTimePad: '7. One-Time Pad',
  CipherType.railFence: '8. Transposição (Rail Fence)',
  CipherType.columnar: '9. Transposição por Colunas',
  CipherType.doubleTransposition: '10. Dupla Transposição',
  CipherType.custom: '11. Cifra Própria (Vigenère + Rail)',
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _key1Controller = TextEditingController();
  final TextEditingController _key2Controller = TextEditingController();
  final TextEditingController _numKeyController = TextEditingController(text: '3');
  String _resultText = "";

  final CaesarCipher _caesarCipher = CaesarCipher();
  final MonoalphabeticCipher _monoCipher = MonoalphabeticCipher();
  final PlayfairCipher _playfairCipher = PlayfairCipher();
  final HillCipher _hillCipher = HillCipher();
  final VigenereCipher _vigenereCipher = VigenereCipher();
  final VernamCipher _vernamCipher = VernamCipher();
  final OneTimePadCipher _otpCipher = OneTimePadCipher();
  final RailFenceCipher _railFenceCipher = RailFenceCipher();
  final ColumnarTranspositionCipher _columnarCipher = ColumnarTranspositionCipher();
  final DoubleTranspositionCipher _doubleCipher = DoubleTranspositionCipher();
  final CustomCipher _customCipher = CustomCipher();

  CipherType _selectedCipher = CipherType.caesar;
  final Random _random = Random();


  void _encrypt() {
    setState(() { _resultText = ""; });
    final String originalText = _textController.text;
    final String key1 = _key1Controller.text;
    final String key2 = _key2Controller.text;
    final int? numKey = int.tryParse(_numKeyController.text);
    String encryptedText = "";
    String? error;

    switch (_selectedCipher) {
      case CipherType.caesar:
        if (numKey == null) error = "Chave numérica inválida.";
        else encryptedText = _caesarCipher.encrypt(originalText, numKey);
        break;
      
      case CipherType.monoalphabetic:
        error = _monoCipher.validateKey(key1);
        if (error == null) encryptedText = _monoCipher.encrypt(originalText, key1);
        break;

      case CipherType.playfair:
      case CipherType.columnar:
        if (key1.isEmpty) error = "A Chave 1 não pode ser vazia.";
        else encryptedText = (_selectedCipher == CipherType.playfair)
            ? _playfairCipher.encrypt(originalText, key1)
            : _columnarCipher.encrypt(originalText, key1);
        break;
      
      case CipherType.hill:
        if (numKey == null || numKey < 2) error = 'm deve ser >= 2.';
        else {
          error = _hillCipher.validateKey(key1, numKey);
          if (error == null) encryptedText = _hillCipher.encrypt(originalText, key1, numKey);
        }
        break;
      
      case CipherType.vigenere:
        error = _vigenereCipher.validateKey(key1);
        if (error == null) encryptedText = _vigenereCipher.encrypt(originalText, key1);
        break;
      
      case CipherType.vernam:
        error = _vernamCipher.validateKey(key1);
        if (error == null) encryptedText = _vernamCipher.encrypt(originalText, key1);
        break;

      case CipherType.oneTimePad:
        encryptedText = _otpCipher.encrypt(originalText, key1);
        if (encryptedText.startsWith('Erro:')) error = encryptedText;
        break;
      
      case CipherType.railFence:
        if (numKey == null || numKey <= 1) error = "Nº de Trilhos deve ser > 1.";
        else encryptedText = _railFenceCipher.encrypt(originalText, numKey);
        break;
      
      case CipherType.doubleTransposition:
        if (key1.isEmpty || key2.isEmpty) error = "Ambas as chaves são obrigatórias.";
        else encryptedText = _doubleCipher.encrypt(originalText, key1, key2);
        break;
      
      case CipherType.custom:
        if (numKey == null || numKey <= 1) error = "Chave Numérica deve ser > 1.";
        else encryptedText = _customCipher.encrypt(originalText, key1, numKey);
        if (encryptedText.startsWith('Erro:')) error = encryptedText;
        break;
    }

    setState(() {
      _resultText = (error != null) ? error : encryptedText;
    });
    if (error == null) {
      AnalysisService.instance.updateTexts(originalText, encryptedText);
    }
  }

  void _decrypt() {
    final String inputText = _resultText.isNotEmpty 
        ? _resultText : _textController.text;
    final String key1 = _key1Controller.text;
    final String key2 = _key2Controller.text;
    final int? numKey = int.tryParse(_numKeyController.text);
    String decryptedText = "";
    String? error;

    switch (_selectedCipher) {
      case CipherType.caesar:
        if (numKey == null) error = "Chave numérica inválida.";
        else decryptedText = _caesarCipher.decrypt(inputText, numKey);
        break;
      
      case CipherType.monoalphabetic:
        error = _monoCipher.validateKey(key1);
        if (error == null) decryptedText = _monoCipher.decrypt(inputText, key1);
        break;

      case CipherType.playfair:
      case CipherType.columnar:
        if (key1.isEmpty) error = "A Chave 1 não pode ser vazia.";
        else decryptedText = (_selectedCipher == CipherType.playfair)
            ? _playfairCipher.decrypt(inputText, key1)
            : _columnarCipher.decrypt(inputText, key1);
        break;
      
      case CipherType.hill:
        if (numKey == null || numKey < 2) error = 'm deve ser >= 2.';
        else {
          error = _hillCipher.validateKey(key1, numKey);
          if (error == null) decryptedText = _hillCipher.decrypt(inputText, key1, numKey);
        }
        break;
      
      case CipherType.vigenere:
        error = _vigenereCipher.validateKey(key1);
        if (error == null) decryptedText = _vigenereCipher.decrypt(inputText, key1);
        break;

      case CipherType.vernam:
        error = _vernamCipher.validateKey(key1);
        if (error == null) decryptedText = _vernamCipher.decrypt(inputText, key1);
        break;

      case CipherType.oneTimePad:
        decryptedText = _otpCipher.decrypt(inputText, key1);
        if (decryptedText.startsWith('Erro:')) error = decryptedText;
        break;
      
      case CipherType.railFence:
        if (numKey == null || numKey <= 1) error = "Nº de Trilhos deve ser > 1.";
        else decryptedText = _railFenceCipher.decrypt(inputText, numKey);
        break;
      
      case CipherType.doubleTransposition:
        if (key1.isEmpty || key2.isEmpty) error = "Ambas as chaves são obrigatórias.";
        else decryptedText = _doubleCipher.decrypt(inputText, key1, key2);
        break;
      
      case CipherType.custom:
        if (numKey == null || numKey <= 1) error = "Chave Numérica deve ser > 1.";
        else decryptedText = _customCipher.decrypt(inputText, key1, numKey);
        if (decryptedText.startsWith('Erro:')) error = decryptedText;
        break;
    }

    setState(() {
      _resultText = (error != null) ? error : decryptedText;
    });

    if (error == null) {
      AnalysisService.instance.updateTexts(decryptedText, inputText);
    }
  }

  void _onCipherChanged(CipherType? newCipher) {
    if (newCipher != null) {
      setState(() {
        _selectedCipher = newCipher;
        _key1Controller.clear();
        _key2Controller.clear();
        _textController.clear();
        _resultText = "";
        _numKeyController.text = "3";
      });
    }
  }

  void _generateKey() {
    const List<String> wordList = [
      'ZEBRA', 'COMPUTADOR', 'MONARQUIA', 'SEGURANCA', 
      'FLUTTER', 'PROJETO', 'CLASSICA', 'CRIPTOGRAFIA'
    ];
    List<String> alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

    String key1 = '';
    String key2 = '';
    String numKey = '';
    bool generated = true;

    switch (_selectedCipher) {
      case CipherType.caesar:
      case CipherType.railFence:
        numKey = (_random.nextInt(5) + 3).toString();
        _numKeyController.text = numKey;
        break;
      
      case CipherType.monoalphabetic:
        alphabet.shuffle(_random);
        key1 = alphabet.join();
        _key1Controller.text = key1;
        break;

      case CipherType.playfair:
      case CipherType.vigenere:
      case CipherType.columnar:
        key1 = wordList[_random.nextInt(wordList.length)];
        _key1Controller.text = key1;
        break;

      case CipherType.doubleTransposition:
        key1 = wordList[_random.nextInt(wordList.length)];
        key2 = wordList[_random.nextInt(wordList.length)];
        _key1Controller.text = key1;
        _key2Controller.text = key2;
        break;
      
      case CipherType.custom:
        key1 = wordList[_random.nextInt(wordList.length)];
        numKey = (_random.nextInt(4) + 2).toString();
        _key1Controller.text = key1;
        _numKeyController.text = numKey;
        break;

      default:
        generated = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geração de chave não suportada para esta cifra.'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }

    if (generated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nova chave aleatória gerada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    String key1Label = "Chave 1 (Texto)";
    String key1Hint = "";
    String key2Label = "Chave 2 (Texto)";
    String key2Hint = "";
    String numKeyLabel = "Chave Numérica";
    String numKeyHint = "";
    bool showKey1 = false;
    bool showKey2 = false;
    bool showNumKey = false;

    switch (_selectedCipher) {
      case CipherType.caesar:
        showNumKey = true;
        numKeyLabel = 'Deslocamento (Chave Numérica)';
        numKeyHint = 'Ex: 3';
        break;
      case CipherType.monoalphabetic:
        showKey1 = true;
        key1Label = 'Chave (Alfabeto de 26 letras)';
        key1Hint = 'Ex: QWERTYUIOPASDFGHJKLZXCVBNM';
        break;
      case CipherType.playfair:
      case CipherType.columnar:
      case CipherType.vigenere:
        showKey1 = true;
        key1Label = 'Chave (Palavra-chave)';
        key1Hint = 'Ex: CHAVE';
        break;
      case CipherType.hill:
        showKey1 = true;
        showNumKey = true;
        int m = int.tryParse(_numKeyController.text) ?? 2;
        key1Label = 'Chave (Texto)';
        key1Hint = 'Pelo menos ${m*m} letras. Ex: GYBNQKURP';
        numKeyLabel = 'Tamanho do Bloco (m)';
        numKeyHint = 'Ex: 2 (para 2x2), 3 (para 3x3)';
        break;
      case CipherType.vernam:
        showKey1 = true;
        key1Label = 'Chave (Pode ser qualquer texto)';
        key1Hint = 'Ex: segredo123!@#';
        break;
      case CipherType.oneTimePad:
        showKey1 = true;
        int textLength = utf8.encode(_textController.text).length;
        key1Label = 'Chave (tão longa quanto o texto)';
        key1Hint = 'Deve ter no mínimo $textLength caracteres/bytes';
        break;
      case CipherType.railFence:
        showNumKey = true;
        numKeyLabel = 'Nº de Trilhos (Chave Numérica)';
        numKeyHint = 'Ex: 3';
        break;
      case CipherType.doubleTransposition:
        showKey1 = true;
        showKey2 = true;
        key1Label = 'Chave 1 (Palavra-chave)';
        key1Hint = 'Ex: PRIMEIRO';
        key2Label = 'Chave 2 (Palavra-chave)';
        key2Hint = 'Ex: SEGUNDO';
        break;
      case CipherType.custom:
        showKey1 = true;
        showNumKey = true;
        key1Label = 'Chave Vigenère (Texto)';
        key1Hint = 'Ex: CHAVE';
        numKeyLabel = 'Chave Rail Fence (Trilhos)';
        numKeyHint = 'Ex: 3';
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<CipherType>(
            value: _selectedCipher,
            items: cipherNames.entries.map((entry) {
              return DropdownMenuItem<CipherType>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: _onCipherChanged,
            decoration: const InputDecoration(
              labelText: 'Selecione o Algoritmo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Texto Original',
              hintText: 'Digite a mensagem aqui',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onChanged: (text) {
              if (_selectedCipher == CipherType.oneTimePad) {
                setState(() {});
              }
              if (_resultText.isNotEmpty) {
                setState(() { _resultText = ""; });
              }
            },
          ),
          const SizedBox(height: 16),
          if (showKey1)
            TextField(
              controller: _key1Controller,
              decoration: InputDecoration(
                labelText: key1Label,
                hintText: key1Hint,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          if (showKey2) const SizedBox(height: 16),
          if (showKey2)
            TextField(
              controller: _key2Controller,
              decoration: InputDecoration(
                labelText: key2Label,
                hintText: key2Hint,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          if (showNumKey) const SizedBox(height: 16),
          if (showNumKey)
            TextField(
              controller: _numKeyController,
              decoration: InputDecoration(
                labelText: numKeyLabel,
                hintText: numKeyHint,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (_selectedCipher == CipherType.hill) {
                  setState(() {});
                }
              },
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text('Cifrar'),
                onPressed: _encrypt,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Decifrar'),
                onPressed: _decrypt,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(Icons.vpn_key_outlined, size: 18),
            label: const Text('Gerar Chave Aleatória'),
            onPressed: _generateKey,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Resultado:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey),
            ),
            constraints: const BoxConstraints(minHeight: 100),
            width: double.infinity,
            child: SelectableText(
              _resultText.isEmpty
                  ? 'O resultado aparecerá aqui...'
                  : _resultText,
              style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}