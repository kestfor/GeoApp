import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class FileHashing {
  static Future<String> computeHash(Uint8List bytes, {Hash algorithm = sha512}) async {
    final digest = algorithm.convert(bytes);
    return digest.toString();
  }

  static Future<String> computeHashFromFile(String filePath, {Hash algorithm = sha256}) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception("File does not exist");
    }

    final bytes = await file.readAsBytes();
    return computeHash(bytes, algorithm: algorithm);
  }
}

