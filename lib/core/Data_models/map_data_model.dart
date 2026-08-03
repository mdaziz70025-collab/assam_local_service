import 'dart:convert';

class MapDataModel {
  MapDataModel({
    this.location,
    this.name,
    this.rating,
    this.photo,
    this.workingHours,
  });

  String? location;
  String? name;
  double? rating;
  dynamic photo;
  WorkingHours? workingHours;

  factory MapDataModel.fromRawJson(String str) =>
      MapDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MapDataModel.fromJson(Map<String, dynamic> json) => MapDataModel(
        location: json["Location"],
        name: json["Name"],
        rating: json["Rating"] != null ? (json["Rating"] as num).toDouble() : null,
        photo: json["Photo"],
        workingHours: json["WorkingHours"] == null
            ? null
            : WorkingHours.fromJson(json["WorkingHours"]),
      );

  Map<String, dynamic> toJson() => {
        "Location": location,
        "Name": name,
        "Rating": rating,
        "Photo": photo,
        "WorkingHours": workingHours?.toJson(),
      };

  @override
  String toString() {
    return "$name, $location, $rating";
  }
}

class WorkingHours {
  WorkingHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  String? monday;
  String? tuesday;
  String? wednesday;
  String? thursday;
  String? friday;
  String? saturday;
  String? sunday;

  factory WorkingHours.fromRawJson(String str) =>
      WorkingHours.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WorkingHours.fromJson(Map<String, dynamic> json) => WorkingHours(
        monday: json["Monday"],
        tuesday: json["Tuesday"],
        wednesday: json["Wednesday"],
        thursday: json["Thursday"],
        friday: json["Friday"],
        saturday: json["Saturday"],
        sunday: json["Sunday"],
      );

  Map<String, dynamic> toJson() => {
        "Monday": monday,
        "Tuesday": tuesday,
        "Wednesday": wednesday,
        "Thursday": thursday,
        "Friday": friday,
        "Saturday": saturday,
        "Sunday": sunday,
      };
}
