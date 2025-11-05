import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:projeto_cifras/ciphers/caesar_cipher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  String _resultText = "";

  final CaesarCipher _cipher = CaesarCipher();

  void _encrypt() {
    final String originalText = _textController.text;
    final String keyText = _keyController.text;

    final int? key = int.tryParse(keyText);
    if (key == null) {
      setState(() {
        _resultText = "Erro: A chave para a Cifra de César deve ser um número.";
      });
      return;
    }
    final String encryptedText = _cipher.encrypt(originalText, key);
    setState(() {
      _resultText = encryptedText;
    });
  }

  void _decrypt() {
    final String originalText = _textController.text;
    final String keyText = _keyController.text;

    final int? key = int.tryParse(keyText);
    if (key == null) {
      setState(() {
        _resultText = "Erro: A chave para a Cifra de César deve ser um número.";
      });
      return;
    }
    final String decryptedText = _cipher.decrypt(originalText, key);
    setState(() {
      _resultText = decryptedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeto 3 - Cifras Clássicas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SELETOR DE CIFRA ---
            Text(
              '1. Cifra de César',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
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

            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Chave (Deslocamento)',
                hintText: 'Digite um número (ex: 3)',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
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