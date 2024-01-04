import 'package:flutter/material.dart';

class StateManagement extends ChangeNotifier {

  String _encryptedText = '';
  String _decryptedText = '';
  String _inputTextEncryption = '';
  String _inputTextDecryption = '';

  String get encryptedText => _encryptedText;
  String get decryptedText => _decryptedText;
  String get inputTextEncryption => _inputTextEncryption;
  String get inputTextDecryption => _inputTextDecryption;

  void setEncryptedText(String text) {
    _encryptedText = text;
    notifyListeners();
  }

  void setDecryptedText(String text) {
    _decryptedText = text;
    notifyListeners();
  }

  void setInputTextEncryption(String text) {
    _inputTextEncryption = text;
    notifyListeners();
  }

  void setInputTextDecryption(String text) {
    _inputTextDecryption = text;
    notifyListeners();
  }

}
