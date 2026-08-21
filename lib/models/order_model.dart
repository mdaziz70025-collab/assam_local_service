import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String category;
  final String status;
  final String customerName;
  final String customerPhone;
  final String address;
  final int amount;
  final String scheduledDate;
  final String slot;
  final String? assignedPartnerId;
  final String? assignedPartnerName;
  final String? partnerPhone;
  final String? completionOtp;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.category,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.amount,
    required this.scheduledDate,
    required this.slot,
    this.assignedPartnerId,
    this.assignedPartnerName,
    this.partnerPhone,
    this.completionOtp,
    this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      category: data['category'] ?? '',
      status: data['status'] ?? 'pending',
      customerName: data['customerName'] ?? data['userName'] ?? 'Customer',
      customerPhone: data['customerPhone'] ?? data['phone'] ?? '',
      address: data['address'] ?? data['customerAddress'] ?? '',
      amount: data['amount'] ?? data['totalAmount'] ?? 0,
      scheduledDate: data['scheduledDate'] ?? data['date'] ?? 'Today',
      slot: data['slot'] ?? data['timeSlot'] ?? '',
      assignedPartnerId: data['assignedPartnerId'],
      assignedPartnerName: data['assignedPartnerName'],
      partnerPhone: data['partnerPhone'],
      completionOtp: data['completionOtp']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'status': status,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'address': address,
      'amount': amount,
      'scheduledDate': scheduledDate,
      'slot': slot,
      if (assignedPartnerId != null) 'assignedPartnerId': assignedPartnerId,
      if (assignedPartnerName != null) 'assignedPartnerName': assignedPartnerName,
      if (partnerPhone != null) 'partnerPhone': partnerPhone,
      if (completionOtp != null) 'completionOtp': completionOtp,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
