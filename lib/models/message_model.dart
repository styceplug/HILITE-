// ─── Sender ───────────────────────────────────────────────────────────────────

import 'package:hilite/models/post_model.dart';

class Sender {
  final String id;
  final String name;
  final String username;
  final String profilePicture;

  const Sender({
    required this.id,
    required this.name,
    required this.username,
    required this.profilePicture,
  });

  factory Sender.fromJson(dynamic j) {
    if (j is String) {
      return Sender(
        id: j,
        name: '',
        username: '',
        profilePicture: MediaUrlHelper.defaultAvatar,
      );
    }

    return Sender(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      username: j['username']?.toString() ?? '',
      profilePicture: MediaUrlHelper.resolveAvatar(j['profilePicture']),
    );
  }
}

// ─── Message ──────────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String chatId;
  final Sender sender;
  final String type;
  final String? text;
  final AudioAttachment? audio;
  final ImageAttachment? image;
  final String? localAudioPath;
  final List<String> readBy;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.type,
    this.text,
    this.audio,
    this.image,
    this.localAudioPath,
    required this.readBy,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
    chatId: j['chat']?.toString() ?? '',
    sender: Sender.fromJson(j['sender']),
    type: j['type']?.toString() ?? 'text',
    text: j['text']?.toString(),
    audio: j['audio'] != null
        ? AudioAttachment.fromJson(Map<String, dynamic>.from(j['audio']))
        : null,
    image: j['image'] != null
        ? ImageAttachment.fromJson(Map<String, dynamic>.from(j['image']))
        : null,
    localAudioPath: null,
    readBy: List<String>.from((j['readBy'] ?? []).map((e) => e.toString())),
    createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );

  ChatMessage copyWith({List<String>? readBy, String? localAudioPath}) => ChatMessage(
    id: id,
    chatId: chatId,
    sender: sender,
    type: type,
    text: text,
    audio: audio,
    image: image,
    localAudioPath: localAudioPath ?? this.localAudioPath,
    readBy: readBy ?? this.readBy,
    createdAt: createdAt,
  );
}

class AudioAttachment {
  final String url;
  final int size;
  final int length;

  const AudioAttachment({
    required this.url,
    required this.size,
    required this.length,
  });

  factory AudioAttachment.fromJson(Map<String, dynamic> j) => AudioAttachment(
    url: MediaUrlHelper.resolve(j['url']),
    size: (j['size'] as num?)?.toInt() ?? 0,
    length: (j['length'] as num?)?.toInt() ?? 0,
  );
}

class ImageAttachment {
  final String url;
  final int size;

  const ImageAttachment({
    required this.url,
    required this.size,
  });

  factory ImageAttachment.fromJson(Map<String, dynamic> j) => ImageAttachment(
    url: MediaUrlHelper.resolve(j['url']),
    size: (j['size'] as num?)?.toInt() ?? 0,
  );
}


// ─── Chat ─────────────────────────────────────────────────────────────────────

class ChatParticipant {
  final String id;
  final String name;
  final String username;
  final String profilePicture;
  final DateTime? lastSeen;

  const ChatParticipant({
    required this.id,
    required this.name,
    required this.username,
    required this.profilePicture,
    this.lastSeen,
  });

  factory ChatParticipant.fromJson(dynamic j) {
    if (j is String) {
      return ChatParticipant(
        id: j,
        name: '',
        username: '',
        profilePicture: MediaUrlHelper.defaultAvatar,
        lastSeen: null,
      );
    }

    return ChatParticipant(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      username: j['username']?.toString() ?? '',
      profilePicture: MediaUrlHelper.resolveAvatar(j['profilePicture']),
      lastSeen: j['lastSeen'] != null
          ? DateTime.tryParse(j['lastSeen'].toString())
          : null,
    );
  }
  String get displayName {
    if (name.trim().isEmpty) {
      return username.isNotEmpty ? username : "User";
    }
    return name;
  }
}

class Chat {
  final String id;
  final List<ChatParticipant> participants;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> j) {
    final participantsRaw = j['participants'] as List? ?? [];

    int resolvedUnreadCount = 0;

    if (j['unreadCount'] is int) {
      resolvedUnreadCount = j['unreadCount'];
    } else if (j['unreadCounts'] is Map<String, dynamic>) {
      final unreadMap = Map<String, dynamic>.from(j['unreadCounts']);
      resolvedUnreadCount = unreadMap.values.fold<int>(
        0,
            (sum, value) => sum + ((value as num?)?.toInt() ?? 0),
      );
    }

    return Chat(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      participants: participantsRaw
          .map((p) => ChatParticipant.fromJson(p))
          .toList(),
      lastMessage: j['lastMessage'] != null
          ? ChatMessage.fromJson(Map<String, dynamic>.from(j['lastMessage']))
          : null,
      unreadCount: resolvedUnreadCount,
      updatedAt: DateTime.tryParse(
        j['updatedAt']?.toString() ?? j['createdAt']?.toString() ?? '',
      ) ??
          DateTime.now(),
    );
  }

  Chat copyWith({
    ChatMessage? lastMessage,
    int? unreadCount,
  }) {
    return Chat(
      id: id,
      participants: participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt,
    );
  }

  ChatParticipant? peer(String myId) {
    for (final p in participants) {
      if (p.id != myId) return p;
    }
    return participants.isNotEmpty ? participants.first : null;
  }
}

// ─── Presence ─────────────────────────────────────────────────────────────────

class UserPresence {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;

  const UserPresence({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
  });

  factory UserPresence.fromJson(Map<String, dynamic> j) => UserPresence(
    userId: j['userId'] ?? '',
    isOnline: j['isOnline'] ?? false,
    lastSeen: j['lastSeen'] != null ? DateTime.tryParse(j['lastSeen']) : null,
  );
}
