import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FileHashing {
  static Future<String> computeHash(Uint8List bytes, {Hash algorithm = sha512}) async {
    final digest = algorithm.convert(bytes);
    return digest.toString();
  }

  static Future<String> computeHashFromFilePath(String filePath, {Hash algorithm = sha256}) async {
    return computeHashFromFile(File(filePath));
  }

  static Future<String> computeHashFromFile(File file, {Hash algorithm = sha256}) async {
    if (!await file.exists()) {
      throw Exception("File does not exist");
    }

    final bytes = await file.readAsBytes();
    return computeHash(bytes, algorithm: algorithm);
  }

  static Future<String> computeHashFromXFile(XFile file, {Hash algorithm = sha256}) async {
    final bytes = await file.readAsBytes();
    return computeHash(bytes, algorithm: algorithm);
  }
}
