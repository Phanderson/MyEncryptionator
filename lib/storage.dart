import "rsa_utils.dart";
import "package:logger/logger.dart";
import "package:pointycastle/export.dart";
import "package:shared_preferences/shared_preferences.dart";

var logger = Logger(
  printer: PrettyPrinter(),
);

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? rsaKeyPair;
RSAPublicKey? public;

// Laden EncryptionScreen
Future<RSAPublicKey> loadPublicKeyFromPreferences() async {
  logger.i("loading public key...");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedModulus = prefs.getString('modulus');
  String? savedPublicExponent = prefs.getString('publicExponent');

  try {
    // Hole den öffentlichen Schlüssel
    final modulus = BigInt.parse(savedModulus!);
    final publicExponent = BigInt.parse(savedPublicExponent!);

    RSAPublicKey public = RSAPublicKey(modulus, publicExponent);
    return public;
  } catch (e) {
    logger.e(e);
    throw Exception('Fehler beim Laden des öffentlichen Schlüssels');
  }
}

Future<RSAPrivateKey> loadDecryptionPrivateKey() async {
  logger.i("loading private key...");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? keyString = prefs.getString('decryptionPrivateKey');

  try {
    return convertPrivateKey(keyString!);
  } catch (e) {
    logger.e('Decryption private key not found');
    throw Exception('Decryption private key not found');
  }
}

void saveDecryptionPrivateKey(privateKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('decryptionPrivateKey', privateKey);
  logger.i("Private decryption key saved..");
}

// Speichern
void saveEncryptionKey(privateKey, publicModulus, publicExponent) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('privateKey', privateKey);
  prefs.setString('modulus', publicModulus);
  prefs.setString('publicExponent', publicExponent);
  logger.i('Key saved successfully!');
}
