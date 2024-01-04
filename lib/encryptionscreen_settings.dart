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
  final TextEditingController _publicKeyController = TextEditingController();

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    // Lade den gespeicherten privaten Schlüssel beim Start der Seite
    loadKeyFromPreferences();
    loadPublicKeyString();
  }

// Laden
  void loadKeyFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPrivateKey = prefs.getString('privateKey');
    logger.i('Private key loaded successfully!');
    setState(() {
      _keyController.text = savedPrivateKey ?? '';
    });
  }

  void loadPublicKeyString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pkeystring = prefs.getString('publicKeyString');
    setState(() {
      _publicKeyController.text = pkeystring ?? '';
    });
  }

  void updateGeneratedKey() {
    setState(() {
      generateNewKeyPair();
      loadKeyFromPreferences();
      loadPublicKeyString();
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  child: SizedBox(
                    height: 100,
                    child: TextField(
                      controller: _publicKeyController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Public Key',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          convertAndSavePublicKeyString(
                              _publicKeyController.text);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_outline),
                            SizedBox(width: 8),
                            Text('Use this public key'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _publicKeyController.text),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.content_copy),
                            SizedBox(width: 8),
                            Text('Copy public key'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await Share.share(_publicKeyController.text);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Share public key'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          savePublicKeyString('');
                          _publicKeyController.clear();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 8),
                            Text('Delete public key'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //Private Key Part
                SingleChildScrollView(
                  child: SizedBox(
                    height: 100,
                    child: TextField(
                      controller: _keyController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Private Key',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
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
                            Text('Use this private key'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
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
                            Text('Copy private key'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
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
                            Text('Share private key'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          Text('Generate new key pair'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
