class NotificationModel {
  String? id;
  String? title;
  String? message;
  String? type; // 'follow', 'like', 'comment', 'system'
  bool? isRead;
  String? createdAt;

  NotificationModel({
    this.id,
    this.title,
    this.message,
    this.type,
    this.isRead,
    this.createdAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
  }
}

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
    readCount = json['read'];
    unreadCount = json['unread'];
  }
}