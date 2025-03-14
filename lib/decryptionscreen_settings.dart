import 'storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DecryptionScreenSettings extends StatefulWidget {
  const DecryptionScreenSettings({Key? key}) : super(key: key);

  @override
  DecryptionScreenSettingsState createState() =>
      DecryptionScreenSettingsState();
}

class DecryptionScreenSettingsState extends State<DecryptionScreenSettings> {
  final TextEditingController _keyController = TextEditingController();

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    loadPrivateKeyForDecryptionSettings();
  }

  void loadPrivateKeyForDecryptionSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPrivateKey = prefs.getString('decryptionPrivateKey');
    logger.i("loading private key for decryption settings..");

    setState(() {
      _keyController.text = savedPrivateKey ?? '';
    });
  }

  void _deleteText() {
    setState(() {
      saveDecryptionPrivateKey('');
      loadPrivateKeyForDecryptionSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decryption Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Speichere den privaten Schlüssel
                        saveDecryptionPrivateKey(_keyController.text);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.key_outlined),
                          SizedBox(width: 8),
                          Text('Use this private key'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: _deleteText,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 8),
                          Text('Delete private key'),
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
