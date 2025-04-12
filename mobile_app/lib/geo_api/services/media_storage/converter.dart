import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:mobile_app/file_processing/image_processing.dart';
import 'package:mobile_app/file_processing/video_processing.dart';
import '../../../file_processing/types.dart';
import 'models/models.dart' as tr;

class Converter {
  static tr.MediaVariant _toMediaVariant(SizeType sizeType) {
    if (sizeType == SizeType.original) {
      return tr.MediaVariant.original;
    } else if (sizeType == SizeType.thumb) {
      return tr.MediaVariant.thumbnail;
    } else if (sizeType == SizeType.medium) {
      return tr.MediaVariant.medium;
    } else {
      throw Exception("Unknown media type");
    }
  }

  static tr.MimeType _toTransportMimeType(String mimeType) {
    if (mimeType == "image/jpeg") {
      return tr.MimeType.imageJpeg;
    } else if (mimeType == "image/jpg") {
      return tr.MimeType.imageJpg;
    } else if (mimeType == "image/png") {
      return tr.MimeType.imagePng;
    } else if (mimeType == "video/mp4") {
      return tr.MimeType.videoMp4;
    } else {
      throw Exception("Unknown mime type");
    }
  }

  static List<tr.MediaRepresentation> _toMediaRepr(ProcessedResult res, tr.MimeType mimeType) {
    List<tr.MediaRepresentation> mediaRepresentations = [];

    for (var entry in res.files.entries) {
      tr.MediaRepresentation mediaRepresentation = tr.MediaRepresentation(
        variant: _toMediaVariant(entry.value.sizeType),
        hash: entry.value.hash,
        hashType: tr.HashType.sha512,
        mimeType: mimeType,
        fileSizeBytes: entry.value.size,
      );
      mediaRepresentation.path = entry.value.filePath;
      mediaRepresentations.add(mediaRepresentation);
    }

    return mediaRepresentations;
  }

  // returns mapping of filepath to MediaFull
  static Future<List<tr.MediaFull>> toTransport(List<HLPickerItem> files) async {
    List<tr.MediaFull> medias = [];
    List<Future<void>> tasks = [];

    for (var file in files) {
      if (file.type == "image") {
        final task = ImageProcessor.processImage(file.path);
        tasks.add(task);
        task.then((res) {
          tr.MediaFull media = tr.MediaFull(
            mediaType: tr.MediaType.photo,
            exifMetadata: res.exifMetadata,
            representations: _toMediaRepr(res, _toTransportMimeType(file.mimeType)),
          );
          medias.add(media);
        });
      } else if (file.type == "video") {
        final task = VideoProcessor.processVideo(file.path, file.thumbnail!);
        tasks.add(task);
        task.then((res) {
          tr.MediaFull media = tr.MediaFull(
            mediaType: tr.MediaType.video,
            exifMetadata: res.exifMetadata,
            representations: _toMediaRepr(res, _toTransportMimeType(file.mimeType)),
          );
          medias.add(media);
        });
      } else {
        throw Exception("Unknown file type");
      }
    }
    await Future.wait(tasks);
    return medias;
  }
}
