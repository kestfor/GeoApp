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
      fileId: json["file_id"],
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
    return ImgData(type: json["type"], url: json["url"], size: json["size"], metadata: json["metadata"]);
  }
}

class ImgContent implements MediaContent {
  final String fileId;
  final String authorId;
  final List<ImgData> images;

  const ImgContent({required this.fileId, required this.authorId, required this.images});

  factory ImgContent.fromJson(Map<String, dynamic> json) {
    return ImgContent(
      fileId: json["file_id"],
      authorId: json["author_id"],
      images: json["images"].map((e) => ImgData.fromJson(e)).toList(),
    );
  }

  @override
  MediaContentType get type => MediaContentType.img;
}

MediaContent resolveFromJson(Map<String, dynamic> json) {
  final type = json["type"];
  switch (type) {
    case "video":
      return VideoContent.fromJson(json);
    case "img":
      return ImgContent.fromJson(json);
    default:
      throw Exception("Unknown media type: $type");
  }
}