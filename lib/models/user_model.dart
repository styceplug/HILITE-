class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String role;
  final String number;
  final String country;
  final String state;
  final String? profilePicture;
  final PlayerDetails? playerDetails;
  final int followers;
  final int following;
  final int blocked;
  final int bookmarks;
  final int posts;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    required this.number,
    required this.country,
    required this.state,
    this.profilePicture,
    this.playerDetails,
    required this.followers,
    required this.following,
    required this.blocked,
    required this.bookmarks,
    required this.posts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      number: json['number'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      profilePicture: json['profilePicture'],
      playerDetails: json['playerDetails'] != null
          ? PlayerDetails.fromJson(json['playerDetails'])
          : null,
      followers: (json['followers'] is List)
          ? json['followers'].length
          : (json['followers'] ?? 0),
      following: (json['following'] is List)
          ? json['following'].length
          : (json['following'] ?? 0),
      blocked: (json['blocked'] is List)
          ? json['blocked'].length
          : (json['blocked'] ?? 0),
      bookmarks: (json['bookmarks'] is List)
          ? json['bookmarks'].length
          : (json['bookmarks'] ?? 0),
      posts: json['posts'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'number': number,
      'country': country,
      'state': state,
      'profilePicture': profilePicture,
      'playerDetails': playerDetails?.toJson(),
      'followers': followers,
      'following': following,
      'blocked': blocked,
      'bookmarks': bookmarks,
      'posts': posts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? number,
    String? country,
    String? state,
    String? profilePicture,
    PlayerDetails? playerDetails,
    int? followers,
    int? following,
    int? blocked,
    int? bookmarks,
    int? posts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      number: number ?? this.number,
      country: country ?? this.country,
      state: state ?? this.state,
      profilePicture: profilePicture ?? this.profilePicture,
      playerDetails: playerDetails ?? this.playerDetails,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      blocked: blocked ?? this.blocked,
      bookmarks: bookmarks ?? this.bookmarks,
      posts: posts ?? this.posts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PlayerDetails {
  final DateTime dob;
  final String position;
  final String currentClub;
  final String preferredFoot;
  final int height;
  final int weight;
  final String bio;

  PlayerDetails({
    required this.dob,
    required this.position,
    required this.currentClub,
    required this.preferredFoot,
    required this.height,
    required this.weight,
    required this.bio,
  });

  factory PlayerDetails.fromJson(Map<String, dynamic> json) {
    return PlayerDetails(
      dob: DateTime.tryParse(json['dob'] ?? '') ?? DateTime.now(),
      position: json['position'] ?? '',
      currentClub: json['currentClub'] ?? '',
      preferredFoot: json['preferredFoot'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dob': dob.toIso8601String(),
      'position': position,
      'currentClub': currentClub,
      'preferredFoot': preferredFoot,
      'height': height,
      'weight': weight,
      'bio': bio,
    };
  }

  PlayerDetails copyWith({
    DateTime? dob,
    String? position,
    String? currentClub,
    String? preferredFoot,
    int? height,
    int? weight,
    String? bio,
  }) {
    return PlayerDetails(
      dob: dob ?? this.dob,
      position: position ?? this.position,
      currentClub: currentClub ?? this.currentClub,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bio: bio ?? this.bio,
    );
  }
}