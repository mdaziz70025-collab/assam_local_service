import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapItemModel {
  String name;
  String location;
  double rating;

  MapItemModel({
    required this.name,
    required this.location,
    required this.rating,
  });

  factory MapItemModel.fromJson(Map<String, dynamic> json) {
    return MapItemModel(
      name: json['Name'] ?? json['name'] ?? '',
      location: json['Location'] ?? json['location'] ?? '',
      rating: json['Rating'] != null ? (json['Rating'] as num).toDouble() : 0.0,
    );
  }
}

class MapDataProvider with ChangeNotifier {
  List<MapItemModel> _mapDataList = [];

  List<MapItemModel> get mapDataList => _mapDataList;

  Future<bool> loadData() async {
    try {
      final String response = await rootBundle.loadString('lib/Temporary_data/map_data.json');
      final data = await json.decode(response) as List;
      _mapDataList = data.map((e) => MapItemModel.fromJson(e)).toList();
      notifyListeners();
      return true;
    } catch (e) {
      print("Error loading map data: $e");
      return false;
    }
  }
}
