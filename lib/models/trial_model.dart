class TrialModel {
  final String id;
  final String name;
  final String location;
  final DateTime date;
  final String? banner;
  final String ageGroup;
  final String type;
  final double registrationFee;
  final String? description;
  final TrialCreator? creator;
  final List<dynamic> registeredIds;
  final List<RegisteredPlayer>? registeredPlayers;

  TrialModel({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    this.banner,
    required this.ageGroup,
    required this.type,
    required this.registrationFee,
    this.description,
    this.creator,
    this.registeredIds = const [],
    this.registeredPlayers,
  });

  factory TrialModel.fromJson(Map<String, dynamic> json) {
    return TrialModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Untitled Trial',
      location: json['location'] ?? 'TBD',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      banner: json['banner'],
      ageGroup: json['ageGroup'] ?? '',
      type: json['type'] ?? 'open',
      registrationFee: (json['registrationFee'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      creator: json['creator'] is Map<String, dynamic>
          ? TrialCreator.fromJson(json['creator'])
          : null,
      registeredIds: json['registered'] is List
          ? List<dynamic>.from(json['registered'])
          : [],
      registeredPlayers: json['registered'] is List &&
          json['registered'].isNotEmpty &&
          json['registered'][0] is Map
          ? List<RegisteredPlayer>.from(
        json['registered'].map((x) => RegisteredPlayer.fromJson(x)),
      )
          : null,
    );
  }

  int get registeredCount =>
      registeredPlayers?.length ?? registeredIds.length;
}

class TrialCreator {
  final String id;
  final String name;
  final String username;
  final String role;
  final String? clubName;
  final String? manager;
  final String? clubType;
  final String? profilePicture;
  final String? state;
  final String? country;

  TrialCreator({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.clubName,
    this.manager,
    this.clubType,
    this.profilePicture,
    this.state,
    this.country,
  });

  factory TrialCreator.fromJson(Map<String, dynamic> json) {
    return TrialCreator(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      clubName: json['clubDetails']?['clubName'],
      manager: json['clubDetails']?['manager'],
      clubType: json['clubDetails']?['clubType'],
      profilePicture: json['profilePicture'],
      state: json['state'],
      country: json['country'],
    );
  }
}

class RegisteredPlayer {
  final String id;
  final String name;
  final String username;
  final String role;
  final String? profilePicture; // <--- Add this

  RegisteredPlayer({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.profilePicture, // <--- Add this
  });

  factory RegisteredPlayer.fromJson(Map<String, dynamic> json) {
    return RegisteredPlayer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'player',
      profilePicture: json['profilePicture'], // <--- Map it here
    );
  }
}