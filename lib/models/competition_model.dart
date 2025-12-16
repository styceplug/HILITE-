class CompetitionModel {
  String? sId;
  Creator? creator;
  String? name;
  String? location;
  String? date;
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
    date = json['date'];
    banner = json['banner'];
    clubsNeeded = json['clubsNeeded'];
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
    }
  }
}

class Creator {
  String? sId;
  String? name;
  String? username;
  String? email;
  String? role;

  Creator({this.sId, this.name, this.username, this.email, this.role});

  Creator.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
  }
}

class RegisteredClub {
  String? sId;
  String? name;
  String? username;
  String? email;
  String? role;

  RegisteredClub({this.sId, this.name, this.username, this.email, this.role});

  RegisteredClub.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
  }
}