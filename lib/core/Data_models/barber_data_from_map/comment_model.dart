import 'dart:convert';

class CommentModel {
  CommentModel({
    this.commentorName,
    this.photo,
    this.time,
    this.comment,
  });

  String? commentorName;
  dynamic photo;
  String? time;
  String? comment;

  factory CommentModel.fromRawJson(String str) =>
      CommentModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        commentorName: json["CommentorName"],
        photo: json["Photo"],
        time: json["Time"],
        comment: json["Comment"],
      );

  Map<String, dynamic> toJson() => {
        "CommentorName": commentorName,
        "Photo": photo,
        "Time": time,
        "Comment": comment,
      };
}
