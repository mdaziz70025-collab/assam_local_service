import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _selectedRating = 5;

  // Direct Phone Call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // Direct WhatsApp Chat
  Future<void> _openWhatsApp(String phoneNumber, String serviceName) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanNumber.startsWith('91') && cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$cleanNumber?text=Hello%20Partner,%20I%20have%20booked%20your%20$serviceName%20service%20via%20Assam%20Local%20Service.",
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  // Post Service Rating Dialog
  void _showRatingDialog(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              "Rate Your Service",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "How was the service provided by our Assam partner?",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() => _selectedRating = index + 1);
                      },
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Skip", style: TextStyle(color: Colors.white38)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('bookings')
                      .doc(orderId)
                      .update({'rating': _selectedRating, 'isRated': true});
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Thank you for your feedback! ⭐"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Live Order Tracking", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Order details not found.", style: TextStyle(color: Colors.white60)),
            );
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final String category = orderData['category'] ?? 'Service';
          final int amount = orderData['totalAmount'] ?? 0;
          final String scheduledDate = orderData['scheduledDate'] ?? 'Today';
          final String slot = orderData['scheduledSlot'] ?? '';
          final String status = orderData['status'] ?? 'Partner Assigned';
          final String partnerName = orderData['assignedPartnerName'] ?? 'Aziz (Verified Pro)';
          final String partnerPhone = orderData['partnerPhone'] ?? '7002521291';
          final bool isRated = orderData['isRated'] ?? false;

          // Status Progress Level (0 to 4)
          int progressLevel = 1;
          if (status.contains("Accepted") || status.contains("Way")) {
            progressLevel = 2;
          } else if (status.contains("Progress")) {
            progressLevel = 3;
          } else if (status.contains("Completed")) {
            progressLevel = 4;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Slot: $scheduledDate ($slot)",
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        "₹ $amount",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Assigned Partner Card with Direct Call & WhatsApp
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                            child: const Icon(Icons.handyman, color: Colors.orangeAccent, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      partnerName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: Colors.greenAccent, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Assam Local Verified • ⭐ 5.0",
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 12),

                      // Call & WhatsApp Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                              label: const Text(
                                "WhatsApp",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _openWhatsApp(partnerPhone, category),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.call, color: Colors.black, size: 18),
                              label: const Text(
                                "Call Partner",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _makePhoneCall(partnerPhone),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Step-by-Step Live Tracking Timeline
                const Text(
                  "Order Status Timeline",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildTimelineStep(
                  title: "Booking Placed",
                  subtitle: "Your request was received successfully",
                  isDone: progressLevel >= 1,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: "Partner Assigned",
                  subtitle: "$partnerName is assigned to your service",
                  isDone: progressLevel >= 1,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: "Partner on the Way",
                  subtitle: "Technician is travelling to your location",
                  isDone: progressLevel >= 2,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: "Work in Progress",
                  subtitle: "Service is being performed at your doorstep",
                  isDone: progressLevel >= 3,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: "Service Completed",
                  subtitle: "Job finished & bill settled",
                  isDone: progressLevel >= 4,
                  isLast: true,
                ),

                const SizedBox(height: 24),

                // 4. Post-Service Rating Button (When Completed)
                if (progressLevel == 4 && !isRated)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.star, color: Colors.black),
                      label: const Text(
                        "RATE THIS SERVICE",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showRatingDialog(widget.orderId),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? Colors.greenAccent : const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? Colors.greenAccent : Colors.white24,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: isDone ? Colors.greenAccent : Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDone ? Colors.white : Colors.white38,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDone ? Colors.white60 : Colors.white24,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
