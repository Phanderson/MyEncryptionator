import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage.dart';
import 'package:logger/logger.dart';
// ignore: implementation_imports
import 'package:pointycastle/src/platform_check/platform_check.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

BigInt? privateExponent;
BigInt? modulus;
BigInt? primeP;
BigInt? primeQ;

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
    SecureRandom secureRandom,
    {int bitLength = 2048}) {
  final keyGen = RSAKeyGenerator();

  keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      secureRandom));

  final pair = keyGen.generateKeyPair();

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

SecureRandom exampleSecureRandom() {
  final secureRandom = SecureRandom('Fortuna')
    ..seed(
        KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
  return secureRandom;
}

Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _processInBlocks(encryptor, dataToEncrypt);
}

Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(
        false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return _processInBlocks(decryptor, cipherText);
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}
//==============Meine Methoden==============

Future<RSAPrivateKey> convertPrivateKey(String keyText) async {
  logger.i("Converting private key...");
  // Extrahiere Private Exponent
  String privateExponentString =
      extractValueBetween(keyText, 'Private Exponent: ', 'Modulus: ');
  privateExponentString = privateExponentString.replaceAll(' ', '');

  // Extrahiere Modulus
  String modulusString = extractValueBetween(keyText, 'Modulus: ', 'P: ');
  modulusString = modulusString.replaceAll(' ', '');

  // Extrahiere P
  String pString = extractValueBetween(keyText, 'P: ', 'Q: ');
  pString = pString.replaceAll(' ', '');

  // Extrahiere Q
  String qString = keyText.substring(keyText.indexOf('Q: ') + 3);
  qString = qString.replaceAll(' ', '');

  logger.i('Private Exponent: $privateExponentString');
  logger.i('Modulus: $modulusString');
  logger.i('P: $pString');
  logger.i('Q: $qString');

  // Parse die BigInt-Werte
  BigInt privateExponent =
      BigInt.tryParse(privateExponentString) ?? BigInt.zero;
  BigInt modulus = BigInt.tryParse(modulusString) ?? BigInt.zero;
  BigInt p = BigInt.tryParse(pString) ?? BigInt.zero;
  BigInt q = BigInt.tryParse(qString) ?? BigInt.zero;

  RSAPrivateKey privateKey = RSAPrivateKey(modulus, privateExponent, p, q);
  return privateKey;
}

void convertAndSavePublicKeyString(String keyText) async {
  logger.i("Converting public key...");
  try {
    // Extrahiere Private Exponent
    String publicExponentString =
        extractValueBetween(keyText, 'Public Exponent: ', 'M: ');
    publicExponentString = publicExponentString.replaceAll(' ', '');

    // Extrahiere Modulus
    String modulusString = keyText.substring(keyText.indexOf('M: ') + 3);
    modulusString = modulusString.replaceAll(' ', '');

    logger.i('Private Exponent: $publicExponentString');
    logger.i('Modulus: $modulusString');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('modulus', publicExponentString);
    prefs.setString('publicExponent', modulusString);
  } catch (e) {
    throw ('Invalid public key.');
  }
}

String extractValueBetween(String text, String start, String end) {
  final startIndex = text.indexOf(start);
  final endIndex = text.indexOf(end, startIndex + start.length);
  return text.substring(startIndex + start.length, endIndex);
}

Future<String> decryptText(
    String encryptedtxt, RSAPrivateKey privateKey) async {
  try {
    logger.i("Decrypting text...");

    // Dekodiere die Base64-kodierte Zeichenfolge in einen Uint8List
    Uint8List encryptedData = base64.decode(encryptedtxt);

    // Entschlüssle den Text
    Uint8List decryptedData = rsaDecrypt(privateKey, encryptedData);

    // Konvertiere den entschlüsselten Uint8List zurück in einen Text
    String decryptedText = utf8.decode(decryptedData);

    return decryptedText;
  } catch (e) {
    logger.e("Fehler beim Entschlüsseln des Textes: $e");
    throw ("Error decrypting the text. Key may be corrupted or wrong.");
  }
}

Future<String> encryptText(textToEncrypt, RSAPublicKey publicKey) async {
  logger.i("Encrypting text...");
  // Konvertiere den Text in einen Uint8List
  Uint8List dataToEncrypt = Uint8List.fromList(utf8.encode(textToEncrypt));

  // Verschlüssle den Text
  Uint8List encryptedData = rsaEncrypt(publicKey, dataToEncrypt);

  // Setze _encryptedText als Base64-kodierte Zeichenfolge
  return base64.encode(encryptedData);
}

//Neues Schlüsselpaar erstellen und Speichern
void generateNewKeyPair() {
  final pair = generateRSAkeyPair(exampleSecureRandom());
  final private = pair.privateKey;
  final public = pair.publicKey;
  logger.i('Key generated!');

  String publicModulus = generateKeyString(public.modulus);
  String publicExponent = generateKeyString(public.publicExponent);

  privateExponent = private.privateExponent;
  modulus = private.n;
  primeP = private.p;
  primeQ = private.q;

  saveEncryptionKey(
      generatePrivateKeyString(privateExponent, modulus, primeP, primeQ),
      publicModulus,
      publicExponent);

  savePublicKeyString('Public Exponent: $publicExponent\nM: $publicModulus');
}

String generatePrivateKeyString(
    BigInt? privateExponent, BigInt? modulus, BigInt? primeP, BigInt? primeQ) {
  return 'Private Exponent: $privateExponent\nModulus: $modulus\nP: $primeP\nQ: $primeQ';
}

String generateKeyString(BigInt? key) {
  return '$key';
}
