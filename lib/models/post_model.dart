

class PostModel {
  final String id;
  final String type;
  final String? text;
  final Author? author;
  final String? authorId;
  final ContentDetails? video;
  final ContentDetails? image;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final bool isLiked;
  final bool isBookmarked;

  PostModel({
    required this.id,
    required this.type,
    this.text,
    this.author,
    this.authorId,
    this.video,
    this.image,
    this.likes = const [],
    this.comments = const [],
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // 🛡️ 1. UNWRAP DATA IF NESTED
    // Mongoose sometimes returns data inside '_doc' or 'post' key
    Map<String, dynamic> data = json;
    if (json.containsKey('_doc') && json['_doc'] is Map) {
      data = json['_doc'];
      // Copy top-level flags (isLiked/isBookmarked) into data if they exist outside _doc
      if (json.containsKey('isLiked')) data['isLiked'] = json['isLiked'];
      if (json.containsKey('isBookmarked')) data['isBookmarked'] = json['isBookmarked'];
    } else if (json.containsKey('post') && json['post'] is Map) {
      data = json['post'];
    }

    // 🛡️ 2. Safe Author Parsing
    Author? parsedAuthor;
    String? parsedAuthorId;

    if (data['author'] is Map<String, dynamic>) {
      parsedAuthor = Author.fromJson(data['author']);
      parsedAuthorId = parsedAuthor.id;
    } else if (data['author'] is String) {
      parsedAuthorId = data['author'];
    }

    return PostModel(
      id: data['_id'] ?? '',
      type: data['type'] ?? 'text',
      text: data['text'],
      author: parsedAuthor,
      authorId: parsedAuthorId,
      video: data['video'] != null ? ContentDetails.fromJson(data['video']) : null,
      image: data['image'] != null ? ContentDetails.fromJson(data['image']) : null,
      likes: data['likes'] ?? [],
      comments: data['comments'] ?? [],
      isLiked: data['isLiked'] ?? false,
      isBookmarked: data['isBookmarked'] ?? false,
    );
  }

}

class Author {
  final String username;
  final String id;
  final String profilePicture;

  Author({required this.username, required this.profilePicture,required this.id});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      username: json['username'] ?? "Unknown",
      profilePicture: json['profilePicture'] ?? "",
      id: json['_id'] ?? "",
    );
  }
}

class ContentDetails {
  final String? url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final double? duration; // Added

  ContentDetails({
    this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.duration,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json) {
    return ContentDetails(
      url: json['url'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: (json['duration'] is int)
          ? (json['duration'] as int).toDouble()
          : json['duration'],
    );
  }
}

class PersonalPostModel {
  String? id;
  String? type; // 'text', 'image', 'video'
  String? text;
  String? mediaUrl;
  String? thumbnail;
  double? duration; // Added from JSON
  DateTime createdAt; // ⚠️ REQUIRED for the sorting logic

  PersonalPostModel({
    this.id,
    this.type,
    this.text,
    this.mediaUrl,
    this.thumbnail,
    this.duration,
    required this.createdAt,
  });

  factory PersonalPostModel.fromJson(Map<String, dynamic> json) {
    String? extractedMediaUrl;
    String? extractedThumbnail;
    double? extractedDuration;

    // 🔧 Handle nested JSON structure
    if (json['type'] == 'image' && json['image'] != null) {
      extractedMediaUrl = json['image']['url'];
    }
    else if (json['type'] == 'video' && json['video'] != null) {
      extractedMediaUrl = json['video']['url'];
      extractedThumbnail = json['video']['thumbnailUrl'] ?? json['video']['thumbnail'];
      // Parse duration safely
      var dur = json['video']['duration'];
      extractedDuration = (dur is int) ? dur.toDouble() : dur;
    }
    else {
      // Fallback
      extractedMediaUrl = json['mediaUrl'] ?? json['file'];
    }

    return PersonalPostModel(
      id: json['_id'],
      type: json['type'],
      text: json['text'],
      mediaUrl: extractedMediaUrl,
      thumbnail: extractedThumbnail,
      duration: extractedDuration,
      // 🗓️ Parse Date (Default to now if missing to prevent sort crash)
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
