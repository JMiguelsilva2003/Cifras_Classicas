import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_cifras/ciphers/caesar_cipher.dart';
import 'package:projeto_cifras/ciphers/monoalphabetic_cipher.dart';
import 'package:projeto_cifras/ciphers/playfair_cipher.dart';
import 'package:projeto_cifras/ciphers/hill_cipher.dart';
import 'package:projeto_cifras/ciphers/vigenere_cipher.dart';
import 'package:projeto_cifras/ciphers/vernam_cipher.dart';

enum CipherType {
  caesar,
  monoalphabetic,
  playfair,
  hill,
  vigenere,
  vernam,
}

const Map<CipherType, String> cipherNames = {
  CipherType.caesar: '1. Cifra de César',
  CipherType.monoalphabetic: '2. Cifra Monoalfabética',
  CipherType.playfair: '3. Cifra de Playfair',
  CipherType.hill: '4. Cifra de Hill',
  CipherType.vigenere: '5. Cifra de Vigenère',
  CipherType.vernam: '6. Cifra de Vernam (com XOR)',
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _mController = TextEditingController(text: '2');
  
  String _resultText = "";

  final CaesarCipher _caesarCipher = CaesarCipher();
  final MonoalphabeticCipher _monoCipher = MonoalphabeticCipher();
  final PlayfairCipher _playfairCipher = PlayfairCipher();
  final HillCipher _hillCipher = HillCipher();
  final VigenereCipher _vigenereCipher = VigenereCipher();
  final VernamCipher _vernamCipher = VernamCipher();

  CipherType _selectedCipher = CipherType.caesar;

  void _encrypt() {
    final String originalText = _textController.text;
    final String keyText = _keyController.text;
    String encryptedText = "";
    String? error;

    switch (_selectedCipher) {
      case CipherType.caesar:
        final int? key = int.tryParse(keyText);
        if (key == null) {
          error = "Erro: A chave para a Cifra de César deve ser um número.";
        } else {
          encryptedText = _caesarCipher.encrypt(originalText, key);
        }
        break;
      
      case CipherType.monoalphabetic:
        error = _monoCipher.validateKey(keyText);
        if (error == null) {
          encryptedText = _monoCipher.encrypt(originalText, keyText);
        }
        break;

      case CipherType.playfair:
        if (keyText.isEmpty) {
          error = "Erro: A chave de Playfair não pode estar vazia.";
        } else {
          encryptedText = _playfairCipher.encrypt(originalText, keyText);
        }
        break;
      
      case CipherType.hill:
        final int? m = int.tryParse(_mController.text);
        if (m == null || m < 2) {
          error = 'Erro: O tamanho do bloco (m) deve ser um número >= 2.';
          break;
        }
        error = _hillCipher.validateKey(keyText, m);
        if (error == null) {
          encryptedText = _hillCipher.encrypt(originalText, keyText, m);
        }
        break;
      
      case CipherType.vigenere:
        error = _vigenereCipher.validateKey(keyText);
        if (error == null) {
          encryptedText = _vigenereCipher.encrypt(originalText, keyText);
        }
        break;
      case CipherType.vernam:
        error = _vernamCipher.validateKey(keyText);
        if (error == null) {
          encryptedText = _vernamCipher.encrypt(originalText, keyText);
        }
        break;
    }

    setState(() {
      _resultText = error ?? encryptedText;
    });
  }

  void _decrypt() {
    final String originalText = _textController.text;
    final String keyText = _keyController.text;
    String decryptedText = "";
    String? error;

    switch (_selectedCipher) {
      case CipherType.caesar:
        final int? key = int.tryParse(keyText);
        if (key == null) {
          error = "Erro: A chave para a Cifra de César deve ser um número.";
        } else {
          decryptedText = _caesarCipher.decrypt(originalText, key);
        }
        break;

      case CipherType.monoalphabetic:
        error = _monoCipher.validateKey(keyText);
        if (error == null) {
          decryptedText = _monoCipher.decrypt(originalText, keyText);
        }
        break;

      case CipherType.playfair:
        if (keyText.isEmpty) {
          error = "Erro: A chave de Playfair não pode estar vazia.";
        } else {
          decryptedText = _playfairCipher.decrypt(originalText, keyText);
        }
        break;

      case CipherType.hill:
        final int? m = int.tryParse(_mController.text);
        if (m == null || m < 2) {
          error = 'Erro: O tamanho do bloco (m) deve ser um número >= 2.';
          break;
        }
        error = _hillCipher.validateKey(keyText, m);
        if (error == null) {
          decryptedText = _hillCipher.decrypt(originalText, keyText, m);
        }
        break;
      
      case CipherType.vigenere:
        error = _vigenereCipher.validateKey(keyText);
        if (error == null) {
          decryptedText = _vigenereCipher.decrypt(originalText, keyText);
        }
        break;

      case CipherType.vernam:
        error = _vernamCipher.validateKey(keyText);
        if (error == null) {
          decryptedText = _vernamCipher.decrypt(originalText, keyText);
        }
        break;
    }

    setState(() {
      _resultText = error ?? decryptedText;
    });
  }

  void _onCipherChanged(CipherType? newCipher) {
    if (newCipher != null) {
      setState(() {
        _selectedCipher = newCipher;
        _keyController.clear();
        _textController.clear();
        _resultText = "";
        _mController.text = "2";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String keyLabel = 'Chave';
    String keyHint = '';
    TextInputType keyKeyboardType = TextInputType.text;
    List<TextInputFormatter> keyFormatters = [];
    TextCapitalization keyCapitalization = TextCapitalization.none;
    bool showMField = false;

    switch (_selectedCipher) {
      case CipherType.caesar:
        keyLabel = 'Chave (Deslocamento)';
        keyHint = 'Digite um número (ex: 3)';
        keyKeyboardType = TextInputType.number;
        keyFormatters = [FilteringTextInputFormatter.digitsOnly];
        break;
      case CipherType.monoalphabetic:
        keyLabel = 'Chave (Alfabeto de 26 letras)';
        keyHint = 'Ex: QWERTYUIOPASDFGHJKLZXCVBNM';
        keyFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))];
        keyCapitalization = TextCapitalization.characters;
        break;
      case CipherType.playfair:
      case CipherType.vigenere:
        keyLabel = 'Chave (Palavra-chave)';
        keyHint = 'Ex: CHAVE';
        keyFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))];
        keyCapitalization = TextCapitalization.characters;
        break;
      case CipherType.hill:
        showMField = true;
        int m = int.tryParse(_mController.text) ?? 2;
        keyLabel = 'Chave ($m x $m = ${m*m} letras)';
        keyHint = 'Ex: GYBNQKURP (para m=3)';
        keyFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))];
        keyCapitalization = TextCapitalization.characters;
        break;
      case CipherType.vernam:
        keyLabel = 'Chave (Pode ser qualquer texto)';
        keyHint = 'Ex: segredo123!@#';
        keyFormatters = [];
        keyCapitalization = TextCapitalization.none;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeto 3 - Cifras Clássicas'),
      ),
      body: SingleChildScrollView(
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
            ),
            const SizedBox(height: 16),

            if (showMField)
              TextField(
                controller: _mController,
                decoration: const InputDecoration(
                  labelText: 'Tamanho do Bloco (m)',
                  hintText: 'Ex: 2 (para 2x2), 3 (para 3x3)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setState(() {}),
              ),
            
            if (showMField) 
              const SizedBox(height: 16),

            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: keyLabel,
                hintText: keyHint,
                border: const OutlineInputBorder(),
              ),
              keyboardType: keyKeyboardType,
              inputFormatters: keyFormatters,
              textCapitalization: keyCapitalization,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open_outlined),
                  label: const Text('Decifrar'),
                  onPressed: _decrypt,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
      ),
    );
  }
}