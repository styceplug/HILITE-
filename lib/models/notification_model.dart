class NotificationResponse {
  List<NotificationModel>? notifications;
  int? readCount;
  int? unreadCount;

  NotificationResponse({this.notifications, this.readCount, this.unreadCount});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <NotificationModel>[];
      json['notifications'].forEach((v) {
        notifications!.add(NotificationModel.fromJson(v));
      });
    }
    readCount = json['read'] ?? 0;
    unreadCount = json['unread'] ?? 0;
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'follow', 'like', 'comment', 'system'
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system', // Default to system if null
      isRead: json['isRead'] ?? false,
      // safely parse dates
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}