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
  final AgentDetails? agentDetails;
  final ClubDetails? clubDetails;
  final double? score;
  final int followers;
  final int following;
  final int blocked;
  final int bookmarks;
  final int posts;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isFollowed;
  bool isBlocked;

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
    this.agentDetails,
    this.clubDetails,
    this.score,
    required this.followers,
    required this.following,
    required this.blocked,
    required this.bookmarks,
    required this.posts,
    required this.createdAt,
    required this.updatedAt,
    this.isFollowed = false,
    this.isBlocked = false,
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
      agentDetails: json['agentDetails'] != null
          ? AgentDetails.fromJson(json['agentDetails'])
          : null,
      clubDetails: json['clubDetails'] != null
          ? ClubDetails.fromJson(json['clubDetails'])
          : null,
      score: (json['score'] is int)
          ? (json['score'] as int).toDouble()
          : (json['score'] ?? 0.0),
      followers: json['followers'] is List
          ? (json['followers'] as List).length
          : (json['followers'] ?? 0),
      following: json['following'] is List
          ? (json['following'] as List).length
          : (json['following'] ?? 0),
      blocked: json['blocked'] is List
          ? (json['blocked'] as List).length
          : (json['blocked'] ?? 0),
      bookmarks: json['bookmarks'] is List
          ? (json['bookmarks'] as List).length
          : (json['bookmarks'] ?? 0),
      posts: json['posts'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isFollowed: json['isFollowed'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
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
      'agentDetails': agentDetails?.toJson(),
      'clubDetails': clubDetails?.toJson(),
      'score': score,
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
    AgentDetails? agentDetails,
    ClubDetails? clubDetails,
    double? score,
    int? followers,
    int? following,
    int? blocked,
    int? bookmarks,
    int? posts,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFollowed,
    bool? isBlocked,
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
      agentDetails: agentDetails ?? this.agentDetails,
      clubDetails: clubDetails ?? this.clubDetails,
      score: score ?? this.score,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      blocked: blocked ?? this.blocked,
      bookmarks: bookmarks ?? this.bookmarks,
      posts: posts ?? this.posts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFollowed: isFollowed ?? this.isFollowed,
      isBlocked: isBlocked ?? this.isBlocked,
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

class AgentDetails {
  final String agencyName;
  final String registrationId;
  final String experience;

  AgentDetails({
    required this.agencyName,
    required this.registrationId,
    required this.experience,
  });

  factory AgentDetails.fromJson(Map<String, dynamic> json) {
    return AgentDetails(
      agencyName: json['agencyName'] ?? '',
      registrationId: json['registrationId'] ?? '',
      experience: json['experience'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agencyName': agencyName,
      'registrationId': registrationId,
      'experience': experience,
    };
  }
}

class ClubDetails {
  final String clubName;
  final String manager;
  final String clubType;
  final String yearFounded;

  ClubDetails({
    required this.clubName,
    required this.manager,
    required this.clubType,
    required this.yearFounded,
  });

  factory ClubDetails.fromJson(Map<String, dynamic> json) {
    return ClubDetails(
      clubName: json['clubName'] ?? '',
      manager: json['manager'] ?? '',
      clubType: json['clubType'] ?? '',
      yearFounded: json['yearFounded'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clubName': clubName,
      'manager': manager,
      'clubType': clubType,
      'yearFounded': yearFounded,
    };
  }
}