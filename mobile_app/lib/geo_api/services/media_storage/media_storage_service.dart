import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../types/media/models_for_transport/models.dart';
import '../../base_api.dart';

class MediaStorageService {
  static final BaseApi baseApi = BaseApi();
  static final String baseUrl = "${BaseApi.baseUrl}/api/content_processor";

  // get presigned urls for uploading files to S3
  Future<Map<String, dynamic>> _getPresUrls(List<MediaFull> media) async {
    for (var entry in media) {
      entry.exifMetadata.clear();
    }

    Map<String, dynamic> body = {"medias": media.map((e) => e.toJson()).toList()};
    final uri = Uri.parse('$baseUrl/upload_urls/');
    var res = await baseApi.post(uri, body: body);
    if (res.statusCode != 200) {
      throw Exception('Failed to get presigned URL');
    } else {
      return jsonDecode(res.body);
    }
  }

  // upload different variants of file to S3
  Future<void> _uploadVariants(MediaFull media, Map<String, dynamic> presData) async {
    final List<MediaRepresentation> reprs = media.representations;
    final List<Future<void>> tasks = [];

    for (int i = 0; i < reprs.length; i++) {
      final hash = reprs[i].hash;
      final filePath = reprs[i].path;
      final fileSize = reprs[i].fileSizeBytes;
      final fields = presData[hash]["fields"];
      final url = presData[hash]["url"];
      final task = _uploadFileToS3(fields, url, filePath, fileSize);
      tasks.add(task);
    }

    try {
      await Future.wait(tasks, eagerError: true);
    } catch (e) {
      log("Error uploading file: $e, one of the tasks failed");
      throw Exception("Error uploading file: $e");
    }
  }

  // assemble fields and url for uploading file directly to S3
  Future<void> _uploadFileToS3(Map<String, dynamic> fields, String url, String filePath, int fileSize) async {
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    var file = File(filePath);
    var stream = http.ByteStream(file.openRead());
    var length = fileSize;
    var multipartFile = http.MultipartFile('file', stream, length, filename: filePath);

    request.files.add(multipartFile);

    final res = await request.send();
    if (res.statusCode == 204) {
      log("file loaded successfully");
    } else {
      String err = 'error uploading file ${res.statusCode}';
      log(err);
      throw err;
    }
  }

  // method for uploading files to S3
  Future<void> uploadFiles(List<MediaFull> media) async {
    final presRes = await _getPresUrls(media);

    for (var med in media) {
      await _uploadVariants(med, presRes);
    }
  }
}
