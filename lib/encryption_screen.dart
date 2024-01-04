import 'rsa_utils.dart';
import 'state_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:pointycastle/pointycastle.dart' as p;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'encryptionscreen_settings.dart';
import 'storage.dart';

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({Key? key}) : super(key: key);

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  late TextEditingController _encryptionController;

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    final encryptionState =
        Provider.of<StateManagement>(context, listen: false);
    super.initState();
    _encryptionController =
        TextEditingController(text: encryptionState.inputTextEncryption);
  }

  void updateEncryptedText(context) async {
    logger.i("Update verschlüsselter Text..");
    p.RSAPublicKey? publicKey;

    final encryptionState =
        Provider.of<StateManagement>(context, listen: false);

    try {
      publicKey = await loadPublicKeyFromPreferences();
    } catch (e) {
      logger.i("Fehler beim Laden des öffentlichen Schlüssels: $e");
    }

    if (publicKey != null) {
      String encryptedText =
          await encryptText(_encryptionController.text, publicKey);
      setState(() {
        encryptionState.setEncryptedText(encryptedText);
      });
    } else {
      generateNewKeyPair();
      publicKey = await loadPublicKeyFromPreferences();
      String encryptedText =
          await encryptText(_encryptionController.text, publicKey);
      setState(() {
        encryptionState.setEncryptedText(encryptedText);
      });
      const snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'Key not found. A new key has been generated. You can change it in the settings.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final encryptionState = Provider.of<StateManagement>(context);
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Text to Encrypt:',
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
                      //Hier ist die Eingabe
                      controller: _encryptionController,
                      onChanged: (text) {
                        encryptionState.setInputTextEncryption(text);
                      },
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Text',
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
                        _encryptionController.clear();
                        encryptionState.setEncryptedText('');
                        encryptionState.setInputTextEncryption('');
                      });
                    },
                    color: Colors.white,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => updateEncryptedText(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Encrypt',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Navigiere zur EncryptionScreenSettings Seite
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const EncryptionScreenSettings()),
                      );
                    },
                    color: Colors.white,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      await Share.share(encryptionState.encryptedText);
                    },
                    color: Colors.white,
                  ),
                  const Expanded(
                    child: Text(
                      'Encrypted Text:',
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
                        ClipboardData(text: encryptionState.encryptedText),
                      );
                    },
                    color: Colors.white,
                  ),
                ],
              ),
              SelectableText(
                //Hier wird der Text angezeigt
                encryptionState.encryptedText,
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
