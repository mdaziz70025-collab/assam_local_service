import 'dart:convert';

import 'map_data_model.dart';
import 'comment_model.dart';
import 'service_model.dart';

class BarberDataFromMapModel {
  BarberDataFromMapModel({
    this.mapData,
    this.services,
    this.gallery,
    this.comments,
  });

  MapDataModel? mapData;
  List<ServiceModel>? services;
  List<dynamic>? gallery;
  List<CommentModel>? comments;

  factory BarberDataFromMapModel.fromRawJson(String str) =>
      BarberDataFromMapModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BarberDataFromMapModel.fromJson(Map<String, dynamic> json) =>
      BarberDataFromMapModel(
        mapData: json["MapData"] == null
            ? null
            : MapDataModel.fromJson(json["MapData"]),
        services: json["Services"] == null
            ? null
            : List<ServiceModel>.from(
                json["Services"].map((x) => ServiceModel.fromJson(x))),
        gallery: json["Gallery"] == null
            ? null
            : List<dynamic>.from(json["Gallery"].map((x) => x)),
        comments: json["Comments"] == null
            ? null
            : List<CommentModel>.from(
                json["Comments"].map((x) => CommentModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "MapData": mapData?.toJson(),
        "Services": services == null
            ? null
            : List<dynamic>.from(services!.map((x) => x.toJson())),
        "Gallery": gallery == null
            ? null
            : List<dynamic>.from(gallery!.map((x) => x)),
        "Comments": comments == null
            ? null
            : List<dynamic>.from(comments!.map((x) => x.toJson())),
      };
}
