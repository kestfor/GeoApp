enum MediaContentType { video, img }

abstract class MediaContent {
  MediaContentType get type;
}

class VideoContent implements MediaContent {
  final String videoUrl;
  final String thumbnailUrl;
  final String fileId;
  final String authorId;

  const VideoContent({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.fileId,
    required this.authorId,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      videoUrl: json["video_url"],
      thumbnailUrl: json["thumbnail_url"],
      fileId: json["media_id"],
      authorId: json["author_id"],
    );
  }

  @override
  MediaContentType get type => MediaContentType.video;
}

class ImgData {
  final String type;
  final String url;
  final int size;
  final Map<String, dynamic> metadata;

  const ImgData({required this.type, required this.url, required this.size, required this.metadata});

  factory ImgData.fromJson(Map<String, dynamic> json) {
    return ImgData(type: json["variant"], url: json["url"], size: json["fileSizeBytes"], metadata: {});
  }
}

class ImgContent implements MediaContent {
  final String fileId;
  final String authorId;
  final Map<String, ImgData> images;

  const ImgContent({required this.fileId, required this.authorId, required this.images});

  factory ImgContent.fromJson(Map<String, dynamic> json) {
    final res = ImgContent(fileId: json["media_id"], authorId: json["author_id"].toString(), images: {});

    for (var item in (json["representations"] as Map).entries) {
      res.images[item.key] = ImgData.fromJson(item.value);
      res.images[item.key]!.metadata.addAll(json["metadata"]);
    }
    return res;
  }

  @override
  MediaContentType get type => MediaContentType.img;
}

MediaContent resolveFromJson(Map<String, dynamic> json) {
  final type = json["type"];
  switch (type) {
    case "video":
      return VideoContent.fromJson(json);
    case "photo":
      return ImgContent.fromJson(json);
    default:
      throw Exception("Unknown media type: $type");
  }
}

String getCover(List<MediaContent> files) {
  for (var file in files) {
    if (file.type == MediaContentType.img) {
      return (file as ImgContent).images["medium"]!.url;
    } else {
      return (file as VideoContent).thumbnailUrl;
    }
  }

  throw Exception("data is empty");
}

String getId(MediaContent file) {
  if (file.type == MediaContentType.img) {
    return (file as ImgContent).fileId;
  } else {
    return (file as VideoContent).fileId;
  }
}
