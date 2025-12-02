class CommentUserModel {
  final String id;
  final String name;
  final String username;
  final String? profilePicture;

  CommentUserModel({
    required this.id,
    required this.name,
    required this.username,
    this.profilePicture,
  });

  factory CommentUserModel.fromJson(Map<String, dynamic> json) {
    return CommentUserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }
}

class CommentModel {
  final String id;
  final String postId;
  final CommentUserModel user;
  final String content;
  final List<dynamic> likes;
  final List<dynamic> replies; // Assuming replies are also IDs or similar
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    required this.likes,
    required this.replies,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? '',
      postId: json['post'] ?? '',
      user: CommentUserModel.fromJson(json['user'] ?? {}),
      content: json['content'] ?? 'No content',
      likes: List<dynamic>.from(json['likes'] ?? []),
      replies: List<dynamic>.from(json['replies'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}