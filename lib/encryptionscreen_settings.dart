import 'storage.dart';
import 'rsa_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionScreenSettings extends StatefulWidget {
  const EncryptionScreenSettings({Key? key}) : super(key: key);

  @override
  EncryptionScreenSettingsState createState() =>
      EncryptionScreenSettingsState();
}

class EncryptionScreenSettingsState extends State<EncryptionScreenSettings> {
  final TextEditingController _keyController = TextEditingController();

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    // Lade den gespeicherten privaten Schlüssel beim Start der Seite
    loadKeyFromPreferences();
  }

// Laden
  void loadKeyFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPrivateKey = prefs.getString('privateKey');
    logger.i('Key loaded successfully!');
    setState(() {
      _keyController.text = savedPrivateKey ?? '';
    });
  }

  void updateGeneratedKey() {
    setState(() {
      generateNewKeyPair();
      loadKeyFromPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encryption Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      height: 200,
                      child: TextField(
                        controller: _keyController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Key',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    //Hier ist der Knopf zum generieren
                    onPressed: updateGeneratedKey,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.key_outlined),
                        SizedBox(width: 8),
                        Text('Generate new key'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: _keyController.text),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.content_copy),
                        SizedBox(width: 8),
                        Text('Copy key'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Share.share(_keyController.text);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share key'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Speichere den privaten Schlüssel
                      saveDecryptionPrivateKey(_keyController.text);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_open_outlined),
                        SizedBox(width: 8),
                        Text('Use same key for Decryption'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
