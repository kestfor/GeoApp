// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchPresignedURLRequest _$BatchPresignedURLRequestFromJson(
  Map<String, dynamic> json,
) => BatchPresignedURLRequest(
  medias:
      (json['medias'] as List<dynamic>)
          .map((e) => MediaFull.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BatchPresignedURLRequestToJson(
  BatchPresignedURLRequest instance,
) => <String, dynamic>{
  'medias': instance.medias.map((e) => e.toJson()).toList(),
};

HTTPValidationError _$HTTPValidationErrorFromJson(Map<String, dynamic> json) =>
    HTTPValidationError(
      detail:
          (json['detail'] as List<dynamic>?)
              ?.map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$HTTPValidationErrorToJson(
  HTTPValidationError instance,
) => <String, dynamic>{
  'detail': instance.detail?.map((e) => e.toJson()).toList(),
};

MediaFull _$MediaFullFromJson(Map<String, dynamic> json) => MediaFull(
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['media_type']),
  exifMetadata: json['exif_metadata'] as Map<String, dynamic>,
  representations:
      (json['representations'] as List<dynamic>)
          .map((e) => MediaRepresentation.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$MediaFullToJson(MediaFull instance) => <String, dynamic>{
  'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
  'exif_metadata': instance.exifMetadata,
  'representations': instance.representations.map((e) => e.toJson()).toList(),
};

const _$MediaTypeEnumMap = {MediaType.photo: 'photo', MediaType.video: 'video'};

MediaRepresentation _$MediaRepresentationFromJson(Map<String, dynamic> json) =>
    MediaRepresentation(
      variant: $enumDecode(_$MediaVariantEnumMap, json['variant']),
      hash: json['hash'] as String,
      hashType: $enumDecode(_$HashTypeEnumMap, json['hash_type']),
      mimeType: $enumDecode(_$MimeTypeEnumMap, json['mime_type']),
      fileSizeBytes: (json['file_size_bytes'] as num).toInt(),
    );

Map<String, dynamic> _$MediaRepresentationToJson(
  MediaRepresentation instance,
) => <String, dynamic>{
  'variant': _$MediaVariantEnumMap[instance.variant]!,
  'hash': instance.hash,
  'hash_type': _$HashTypeEnumMap[instance.hashType]!,
  'mime_type': _$MimeTypeEnumMap[instance.mimeType]!,
  'file_size_bytes': instance.fileSizeBytes,
};

const _$MediaVariantEnumMap = {
  MediaVariant.thumbnail: 'thumbnail',
  MediaVariant.medium: 'medium',
  MediaVariant.original: 'original',
};

const _$HashTypeEnumMap = {
  HashType.md5: 'md5',
  HashType.sha1: 'sha1',
  HashType.sha256: 'sha256',
  HashType.sha512: 'sha512',
};

const _$MimeTypeEnumMap = {
  MimeType.imageJpeg: 'image/jpeg',
  MimeType.imageJpg: 'image/jpg',
  MimeType.imagePng: 'image/png',
  MimeType.videoMp4: 'video/mp4',
};

ValidationError _$ValidationErrorFromJson(Map<String, dynamic> json) =>
    ValidationError(
      loc: json['loc'] as List<dynamic>,
      msg: json['msg'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$ValidationErrorToJson(ValidationError instance) =>
    <String, dynamic>{
      'loc': instance.loc,
      'msg': instance.msg,
      'type': instance.type,
    };
