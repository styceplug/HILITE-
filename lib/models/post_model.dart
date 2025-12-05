/*
class PostModel {
  final String id;
  final String type;
  final String? text;
  final AuthorModel author;

  final VideoModel? video;
  final ImageModel? image;

  final List<dynamic> likes;
  final List<dynamic> views;

  final bool isPublic;
  final bool hasViewed;
  final double score;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.type,
    this.text,
    required this.author,
    this.video,
    this.image,
    required this.likes,
    required this.views,
    required this.isPublic,
    required this.hasViewed,
    required this.score,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'],
      type: json['type'],
      text: json['text'],
      author: AuthorModel.fromJson(json['author']),
      video: json['video'] != null ? VideoModel.fromJson(json['video']) : null,
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
      likes: json['likes'] ?? [],
      views: json['views'] ?? [],
      isPublic: json['isPublic'] ?? true,
      hasViewed: json['hasViewed'] ?? false,
      score: (json['score'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AuthorModel {
  final String id;
  final String username;

  AuthorModel({
    required this.id,
    required this.username,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['_id'],
      username: json['username'] ?? '',
    );
  }
}

class VideoModel {
  final String url;
  final String title;
  final String description;
  final String thumbnailUrl;
  final double duration;

  VideoModel({
    required this.url,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.duration,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      url: json['url'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      duration: (json['duration'] ?? 0).toDouble(),
    );
  }
}

class ImageModel {
  final String url;
  final String title;
  final String description;

  ImageModel({
    required this.url,
    required this.title,
    required this.description,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}*/


import 'dart:ffi';

class PostModel {
  final String id;
  final String type;
  final String? text;
  final Author? author;
  final ContentDetails? video;
  final ContentDetails? image;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.type,
    this.text,
    this.author,
    this.video,
    this.image,
    this.likes = const [],
    this.comments = const [],
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'],
      type: json['type'] ?? 'text',
      text: json['text'],
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      video: json['video'] != null ? ContentDetails.fromJson(json['video']) : null,
      image: json['image'] != null ? ContentDetails.fromJson(json['image']) : null,
      likes: json['likes'] ?? [],
      comments: json['comments'] ?? [],
      isLiked: json['isLiked'] ?? false,
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

  ContentDetails({this.url, this.title, this.description, this.thumbnailUrl});

  factory ContentDetails.fromJson(Map<String, dynamic> json) {
    return ContentDetails(
      url: json['url'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class PersonalPostModel {
  String? id;
  String? type; // 'text', 'image', 'video'
  String? text;
  String? mediaUrl;
  String? thumbnail;

  PersonalPostModel({this.id, this.type, this.text, this.mediaUrl, this.thumbnail});

  PersonalPostModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    type = json['type'];
    text = json['text'];

    // 🔧 FIX: Handle the nested JSON structure correctly
    if (type == 'image' && json['image'] != null) {
      // The API returns "image": { "url": "..." }
      mediaUrl = json['image']['url'];
    }
    else if (type == 'video' && json['video'] != null) {
      // Assuming video follows the same pattern
      mediaUrl = json['video']['url'];
      thumbnail = json['video']['thumbnailUrl'] ?? json['video']['thumbnail'];    }
    // Fallback if the API changes structure or sends 'file'
    else {
      mediaUrl = json['mediaUrl'] ?? json['file'];
    }
  }
}
