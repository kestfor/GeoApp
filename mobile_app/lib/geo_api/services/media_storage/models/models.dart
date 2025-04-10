import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class BatchPresignedURLRequest {
  final List<MediaFull> medias;

  BatchPresignedURLRequest({required this.medias});

  factory BatchPresignedURLRequest.fromJson(Map<String, dynamic> json) => _$BatchPresignedURLRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BatchPresignedURLRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class HTTPValidationError {
  final List<ValidationError>? detail;

  HTTPValidationError({this.detail});

  factory HTTPValidationError.fromJson(Map<String, dynamic> json) => _$HTTPValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$HTTPValidationErrorToJson(this);
}

enum HashType { md5, sha1, sha256, sha512 }

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MediaFull {
  final MediaType mediaType;
  final Map<String, dynamic> exifMetadata;
  final List<MediaRepresentation> representations;

  MediaFull({required this.mediaType, required this.exifMetadata, required this.representations});

  factory MediaFull.fromJson(Map<String, dynamic> json) => _$MediaFullFromJson(json);

  Map<String, dynamic> toJson() => _$MediaFullToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MediaRepresentation {
  final MediaVariant variant;
  final String hash;
  final HashType hashType;
  final MimeType mimeType;
  final int fileSizeBytes;
  String? _path;

  MediaRepresentation({
    required this.variant,
    required this.hash,
    required this.hashType,
    required this.mimeType,
    required this.fileSizeBytes,
  });

  set path(String path) {
    _path = path;
  }

  String get path => _path ?? "";

  factory MediaRepresentation.fromJson(Map<String, dynamic> json) => _$MediaRepresentationFromJson(json);

  Map<String, dynamic> toJson() => _$MediaRepresentationToJson(this);
}

enum MediaType { photo, video }

enum MediaVariant { thumbnail, medium, original }

enum MimeType {
  @JsonValue('image/jpeg')
  imageJpeg,
  @JsonValue('image/jpg')
  imageJpg,
  @JsonValue('image/png')
  imagePng,
  @JsonValue('video/mp4')
  videoMp4,
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ValidationError {
  final List<dynamic> loc;
  final String msg;
  final String type;

  ValidationError({required this.loc, required this.msg, required this.type});

  factory ValidationError.fromJson(Map<String, dynamic> json) => _$ValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}
