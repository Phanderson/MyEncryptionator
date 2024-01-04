import 'state_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:pointycastle/pointycastle.dart' as p;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'decryptionscreen_settings.dart';
import 'storage.dart';
import 'rsa_utils.dart';

class DecryptionScreen extends StatefulWidget {
  const DecryptionScreen({Key? key}) : super(key: key);

  @override
  State<DecryptionScreen> createState() => _DecryptionScreenState();
}

class _DecryptionScreenState extends State<DecryptionScreen> {
  late TextEditingController _decryptionController;

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    final decryptionState =
        Provider.of<StateManagement>(context, listen: false);
    super.initState();
    _decryptionController =
        TextEditingController(text: decryptionState.inputTextDecryption);
  }

  void updateDecryptedText(context) async {
    logger.i("Update Entschlüsselter Text..");
    p.RSAPrivateKey? privateKey;

    final decryptionState =
        Provider.of<StateManagement>(context, listen: false);

    try {
      privateKey = await loadDecryptionPrivateKey();
    } catch (e) {
      logger.i("Fehler beim Laden des privaten Schlüssels: $e");

      // Zeige eine Snackbar mit der Fehlermeldung
      const snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No private key found'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return; // Beende die Methode, da der private Schlüssel nicht geladen werden konnte
    }

    try {
      String decryptedText =
          await decryptText(_decryptionController.text, privateKey);
      setState(() {
        decryptionState.setDecryptedText(decryptedText);
      });
    } catch (decryptError) {
      logger.e("Fehler beim Entschlüsseln des Textes: $decryptError");

      // Zeige eine Snackbar mit der Fehlermeldung beim Entschlüsseln
      final snackBar = SnackBar(
          behavior: SnackBarBehavior.floating, content: Text('$decryptError'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decryptionState = Provider.of<StateManagement>(context);
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Text to Decrypt:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: 200,
                    child: TextField(
                      controller: _decryptionController,
                      onChanged: (text) {
                        decryptionState.setInputTextDecryption(text);
                      },
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Encrypted Text',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        decryptionState.setInputTextDecryption('');
                        decryptionState.setDecryptedText('');
                        _decryptionController.clear();
                      });
                    },
                    color: Colors.white,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => updateDecryptedText(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Decrypt',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Navigiere zur DecryptionScreenSettings Seite
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DecryptionScreenSettings()),
                      );
                    },
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      await Share.share(decryptionState.decryptedText);
                    },
                    color: Colors.white,
                  ),
                  const Expanded(
                    child: Text(
                      'Decrypted Text:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: decryptionState.decryptedText),
                      );
                    },
                    color: Colors.white,
                  ),
                ],
              ),
              SelectableText(
                decryptionState.decryptedText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
