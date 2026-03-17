import 'package:flutter/material.dart';


const String defaultAvatar =
    "https://ui-avatars.com/api/?background=444&color=fff&name=User";

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
    Map<String, dynamic> data = json;
    if (json.containsKey('_doc') && json['_doc'] is Map) {
      data = Map<String, dynamic>.from(json['_doc']);
      if (json.containsKey('isLiked')) data['isLiked'] = json['isLiked'];
      if (json.containsKey('isBookmarked')) data['isBookmarked'] = json['isBookmarked'];
    } else if (json.containsKey('post') && json['post'] is Map) {
      data = Map<String, dynamic>.from(json['post']);
    }

    debugPrint('🧩 Parsing PostModel: ${data['_id']}');
    debugPrint('   authorPic(raw): ${data['author'] is Map ? data['author']['profilePicture'] : null}');
    debugPrint('   videoUrl(raw): ${data['video']?['url']}');
    debugPrint('   thumb(raw): ${data['video']?['thumbnailUrl']}');

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

  Author({
    required this.username,
    required this.id,
    required this.profilePicture,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      username: json['username'] ?? "Unknown",
      profilePicture: MediaUrlHelper.resolveAvatar(json['profilePicture']),
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
      url: MediaUrlHelper.resolve(json['url']),
      title: json['title'],
      description: json['description'],
      thumbnailUrl: MediaUrlHelper.resolveNullable(json['thumbnailUrl']),
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

    if (json['type'] == 'image' && json['image'] != null) {
      extractedMediaUrl = MediaUrlHelper.resolve(json['image']['url']);
    } else if (json['type'] == 'video' && json['video'] != null) {
      extractedMediaUrl = MediaUrlHelper.resolve(json['video']['url']);
      extractedThumbnail = MediaUrlHelper.resolve(
        json['video']['thumbnailUrl'] ?? json['video']['thumbnail'],
      );
      var dur = json['video']['duration'];
      extractedDuration = (dur is int) ? dur.toDouble() : dur;
    } else {
      extractedMediaUrl = MediaUrlHelper.resolve(json['mediaUrl'] ?? json['file']);
    }

    return PersonalPostModel(
      id: json['_id'],
      type: json['type'],
      text: json['text'],
      mediaUrl: extractedMediaUrl,
      thumbnail: extractedThumbnail,
      duration: extractedDuration,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class MediaUrlHelper {
  static const String baseUrl = 'https://api.hiliteapp.net';

  static const String defaultAvatar =
      "https://cdn-icons-png.flaticon.com/512/149/149071.png";

  static String resolveAvatar(dynamic path) {
    if (path == null) return defaultAvatar;

    final value = path.toString().trim();
    if (value.isEmpty) return defaultAvatar;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }

  static String resolve(dynamic path) {
    if (path == null) return '';

    final value = path.toString().trim();
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }

  static String? resolveNullable(dynamic path) {
    if (path == null) return null;

    final value = path.toString().trim();
    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }
}

