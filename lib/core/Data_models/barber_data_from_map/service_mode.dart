import 'dart:convert';

class ServiceModel {
  ServiceModel({
    this.serviceName,
    this.price,
  });

  String? serviceName;
  int? price;

  factory ServiceModel.fromRawJson(String str) =>
      ServiceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        serviceName: json["ServiceName"],
        price: json["Price"],
      );

  Map<String, dynamic> toJson() => {
        "ServiceName": serviceName,
        "Price": price,
      };
}
