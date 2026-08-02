import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceProviderDataModel {
  String name;
  String category;
  String location;
  double rating;
  String phone;

  ServiceProviderDataModel({
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.phone,
  });

  factory ServiceProviderDataModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderDataModel(
      name: json['Name'] ?? json['name'] ?? '',
      category: json['category'] ?? 'General Service',
      location: json['Location'] ?? json['location'] ?? '',
      rating: json['Rating'] != null ? (json['Rating'] as num).toDouble() : 0.0,
      phone: json['phone'] ?? '',
    );
  }
}

class BarberDataFromMapProvider with ChangeNotifier {
  List<ServiceProviderDataModel> _serviceProviders = [];

  List<ServiceProviderDataModel> get serviceProviders => _serviceProviders;

  Future<bool> loadData() async {
    try {
      final String response = await rootBundle.loadString('lib/Temporary_data/map_data.json');
      final data = await json.decode(response) as List;
      _serviceProviders = data.map((e) => ServiceProviderDataModel.fromJson(e)).toList();
      notifyListeners();
      return true;
    } catch (e) {
      print("Error loading service provider data: $e");
      return false;
    }
  }
}
