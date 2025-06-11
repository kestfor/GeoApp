import 'package:latlong2/latlong.dart';

enum SizeType { thumb, medium, original }

class Size {
  final double width;
  final double height;
  Size(this.width, this.height);
}

class FileInfo {
  final String filePath;
  final String hash;
  final int size;
  final SizeType sizeType;

  FileInfo({required this.filePath, required this.hash, required this.size, required this.sizeType});
}

class ProcessedResult {
  final Map<SizeType, FileInfo> files;
  final Map<String, dynamic> exifMetadata;


  LatLng? extractLatLng() {;
    if (exifMetadata.containsKey('latitude') && exifMetadata.containsKey('longitude')) {
      return LatLng(
        exifMetadata['latitude'] as double,
        exifMetadata['longitude'] as double,
      );
    }
    return null;
  }

  ProcessedResult({required this.files, required this.exifMetadata});
}