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
  final List<dynamic> registeredIds; // Used in /v1/trial and trial creation
  final List<RegisteredPlayer>? registeredPlayers; // Used in /v1/trial/{trialId}

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
      // Creator can be ID string (on creation) or object (on retrieval)
      creator: json['creator'] is Map ? TrialCreator.fromJson(json['creator']) : null,

      // Handles registered list from /v1/trial (list of IDs)
      registeredIds: json['registered'] is List ? List<dynamic>.from(json['registered']) : [],

      // Handles registered list from /v1/trial/{trialId} (list of objects)
      registeredPlayers: json['registered'] is List && json['registered'].isNotEmpty && json['registered'][0] is Map
          ? List<RegisteredPlayer>.from(json['registered'].map((x) => RegisteredPlayer.fromJson(x)))
          : null,
    );
  }
}

class TrialCreator {
  final String id;
  final String name;
  final String username;
  final String role;

  TrialCreator({required this.id, required this.name, required this.username, required this.role});

  factory TrialCreator.fromJson(Map<String, dynamic> json) {
    return TrialCreator(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class RegisteredPlayer {
  final String id;
  final String name;
  final String username;
  final String role;

  RegisteredPlayer({required this.id, required this.name, required this.username, required this.role});

  factory RegisteredPlayer.fromJson(Map<String, dynamic> json) {
    return RegisteredPlayer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'player',
    );
  }
}