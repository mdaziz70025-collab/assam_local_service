import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../chat/chat_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderId;

  const OrderTrackingScreen({Key? key, this.orderId}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _selectedRating = 5;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

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

  Future<void> _openHelpSupport(String? currentOrderId) async {
    final orderText = currentOrderId != null ? "regarding%20Order%20ID:%20$currentOrderId" : "regarding%20my%20recent%20booking";
    final Uri helpUri = Uri.parse(
      "https://wa.me/917002521291?text=Hello%20Assam%20Local%20Service%20Support,%20I%20need%20help%20$orderText.",
    );
    if (await canLaunchUrl(helpUri)) {
      await launchUrl(helpUri, mode: LaunchMode.externalApplication);
    }
  }

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          widget.orderId != null ? "Live Order Tracking" : "My Bookings & Orders",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.orangeAccent, size: 20),
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            onSelected: (value) {
              if (value == 'refresh') {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Orders updated! 🔄"),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
              } else if (value == 'help') {
                _openHelpSupport(widget.orderId);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.cyanAccent, size: 18),
                    SizedBox(width: 10),
                    Text("Refresh Orders", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.greenAccent, size: 18),
                    SizedBox(width: 10),
                    Text("Booking Help & Support", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                "Please login to view your orders",
                style: TextStyle(color: Colors.white60),
              ),
            )
          : widget.orderId != null
              ? _buildSingleOrderStream(widget.orderId!)
              : _buildUserOrdersList(user.uid),
    );
  }

  Widget _buildSingleOrderStream(String orderId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').doc(orderId).snapshots(),
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
        return _buildDetailedOrderView(orderId, orderData);
      },
    );
  }

  Widget _buildUserOrdersList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.white24, size: 48),
                SizedBox(height: 12),
                Text(
                  "No bookings placed yet",
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Your active service orders will appear here.",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final String status = data['status'] ?? 'Pending Partner Acceptance';
            final String category = data['category'] ?? 'Service';
            final int amount = data['totalAmount'] ?? 0;
            final bool isCompleted = status == "Service Completed";

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingScreen(orderId: doc.id),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.greenAccent.withOpacity(0.4)
                        : Colors.orangeAccent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(status, style: TextStyle(color: isCompleted ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("₹ $amount", style: const TextStyle(color: Colors.orangeAccent, fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailedOrderView(String orderId, Map<String, dynamic> orderData) {
    final String category = orderData['category'] ?? 'Service';
    final int amount = orderData['totalAmount'] ?? 0;
    final String scheduledDate = orderData['scheduledDate'] ?? 'Today';
    final String slot = orderData['scheduledSlot'] ?? '';
    final String status = orderData['status'] ?? 'Pending Partner Acceptance';
    final String partnerName = orderData['assignedPartnerName'] ?? 'Assigning Partner...';
    final String partnerPhone = orderData['partnerPhone'] ?? '7002521291';
    final String completionOtp = orderData['completionOtp'] ?? '----';
    final bool isRated = orderData['isRated'] ?? false;
    final bool isAccepted = status.contains("Accepted");

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
          // Order Summary Card
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
                    Text(category, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Slot: $scheduledDate ($slot)", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
                Text("₹ $amount", style: const TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Completion OTP Card
          if (isAccepted && progressLevel < 4) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Completion OTP", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text("Share with partner when job is done", style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                  Text(
                    completionOtp,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Partner Details Card
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
                              Text(partnerName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Colors.greenAccent, size: 16),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text("Assam Local Verified • ⭐ 5.0", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                        label: const Text("WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () => _openWhatsApp(partnerPhone, category),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.message, color: Colors.white, size: 18),
                        label: const Text("In-App Chat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(orderId: orderId, receiverName: partnerName),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.orangeAccent),
                      icon: const Icon(Icons.call, color: Colors.black, size: 20),
                      onPressed: () => _makePhoneCall(partnerPhone),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timeline
          const Text("Order Status Timeline", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                label: const Text("RATE THIS SERVICE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () => _showRatingDialog(orderId),
              ),
            ),
        ],
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
