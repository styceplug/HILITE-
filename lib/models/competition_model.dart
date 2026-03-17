import 'package:hilite/models/post_model.dart';

class CompetitionModel {
  String? sId;
  Creator? creator;
  String? name;
  String? location;
  DateTime? date;
  String? banner;
  String? clubsNeeded;
  int? registrationFee;
  int? prize;
  String? description;
  List<dynamic>? registered;

  CompetitionModel({
    this.sId,
    this.creator,
    this.name,
    this.location,
    this.date,
    this.banner,
    this.clubsNeeded,
    this.registrationFee,
    this.prize,
    this.description,
    this.registered,
  });

  CompetitionModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    creator = json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    name = json['name'];
    location = json['location'];
    date = DateTime.tryParse(json['date']?.toString() ?? '');
    banner = MediaUrlHelper.resolve(json['banner']);
    clubsNeeded = json['clubsNeeded']?.toString();
    registrationFee = int.tryParse(json['registrationFee'].toString());
    prize = int.tryParse(json['prize'].toString());
    description = json['description'];

    if (json['registered'] != null) {
      registered = [];
      for (var v in json['registered']) {
        if (v is String) {
          registered!.add(v);
        } else {
          registered!.add(RegisteredClub.fromJson(v));
        }
      }
    } else {
      registered = [];
    }
  }

  int get registeredCount => registered?.length ?? 0;

  List<RegisteredClub> get registeredClubs {
    if (registered == null) return [];
    return registered!.whereType<RegisteredClub>().toList();
  }
}

class Creator {
  String? sId;
  String? name;
  String? username;
  String? email;
  String? role;
  String? clubName;
  String? manager;
  String? clubType;
  String? state;
  String? country;
  String? profilePicture;

  Creator({
    this.sId,
    this.name,
    this.username,
    this.email,
    this.role,
    this.clubName,
    this.manager,
    this.clubType,
    this.state,
    this.country,
    this.profilePicture,
  });

  Creator.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    clubName = json['clubDetails']?['clubName'];
    manager = json['clubDetails']?['manager'];
    clubType = json['clubDetails']?['clubType'];
    state = json['state'];
    country = json['country'];
    profilePicture = MediaUrlHelper.resolveAvatar(json['profilePicture']);
  }
}

class RegisteredClub {
  String? sId;
  String? name;
  String? username;
  String? email;
  String? role;
  String? clubName;
  String? profilePicture;

  RegisteredClub({
    this.sId,
    this.name,
    this.username,
    this.email,
    this.role,
    this.clubName,
    this.profilePicture,
  });

  RegisteredClub.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    clubName = json['clubDetails']?['clubName'];
    profilePicture = MediaUrlHelper.resolveAvatar(json['profilePicture']);
  }
}