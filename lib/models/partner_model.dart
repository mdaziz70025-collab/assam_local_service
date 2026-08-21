import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerModel {
  final String uid;
  final String name;
  final String phone;
  final String category;
  final String location;
  final int baseRate;
  final double rating;
  final int totalJobs;
  final int totalEarnings;
  final bool isOnline;
  final String? fcmToken;
  final DateTime? registeredAt;

  PartnerModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.category,
    required this.location,
    this.baseRate = 299,
    this.rating = 5.0,
    this.totalJobs = 0,
    this.totalEarnings = 0,
    this.isOnline = true,
    this.fcmToken,
    this.registeredAt,
  });

  factory PartnerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PartnerModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      category: data['category'] ?? 'Electrician',
      location: data['location'] ?? 'Assam',
      baseRate: data['baseRate'] ?? 299,
      rating: (data['rating'] ?? 5.0).toDouble(),
      totalJobs: data['totalJobs'] ?? 0,
      totalEarnings: data['totalEarnings'] ?? 0,
      isOnline: data['isOnline'] ?? true,
      fcmToken: data['fcmToken'],
      registeredAt: (data['registeredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'category': category,
      'location': location,
      'baseRate': baseRate,
      'rating': rating,
      'totalJobs': totalJobs,
      'totalEarnings': totalEarnings,
      'isOnline': isOnline,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'registeredAt': FieldValue.serverTimestamp(),
    };
  }
}
