import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapDataProvider with ChangeNotifier {
  List<dynamic> _mapData = [];

  List<dynamic> get mapData => _mapData;

  Future<void> loadMapData() async {
    try {
      final String response = await rootBundle.loadString('lib/Temporary_data/map_data.json');
      final data = await json.decode(response);
      _mapData = data;
      notifyListeners();
    } catch (e) {
      print("Error loading map data: $e");
    }
  }
}
