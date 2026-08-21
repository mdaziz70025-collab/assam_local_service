import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/notification_service.dart';
import '../chat/chat_screen.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({Key? key}) : super(key: key);

  @override
  _ProviderRegistrationScreenState createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCategory = 'Electrician';
  final List<String> _categories = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Barber / Salon',
    'Mason (Mistri)',
    'Home Cleaning',
    'Painter',
    'AC Repair',
  ];

  StreamSubscription<QuerySnapshot>? _orderStreamSubscription;
  final Set<String> _shownOrderPopupIds = {};

  @override
  void dispose() {
    _orderStreamSubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _listenForNewIncomingOrders(
      String category, String partnerName, String partnerPhone, String partnerLocation, bool isOnline) {
    if (!isOnline) {
      _orderStreamSubscription?.cancel();
      _orderStreamSubscription = null;
      return;
    }

    if (_orderStreamSubscription != null) return;

    final String partnerCity = partnerLocation.toLowerCase().trim();

    _orderStreamSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('category', isEqualTo: category)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final orderId = change.doc.id;
          final status = data['status'] ?? '';
          final custAddress = (data['customerAddress'] ?? '').toString().toLowerCase();

          // 📍 Location Filtering for Alert Popups
          bool matchesLocation = custAddress.contains(partnerCity) ||
              partnerCity.contains("assam") ||
              partnerCity.isEmpty;

          if (status == 'Pending Partner Acceptance' &&
              matchesLocation &&
              !_shownOrderPopupIds.contains(orderId)) {
            _shownOrderPopupIds.add(orderId);

            NotificationService.showInstantNotification(
              "🔔 New $category Order in $partnerLocation!",
              "${data['customerName']} booked an order of ₹${data['totalAmount']}",
            );

            _showIncomingOrderModal(orderId, data, partnerName, partnerPhone);
          }
        }
      }
    });
  }

  void _showIncomingOrderModal(String orderId, Map<String, dynamic> orderData,
      String partnerName, String partnerPhone) {
    if (!mounted) return;

    final customerName = orderData['customerName'] ?? 'Customer';
    final amount = orderData['totalAmount'] ?? 0;
    final scheduledDate = orderData['scheduledDate'] ?? 'Today';
    final slot = orderData['scheduledSlot'] ?? '';
    final address = orderData['customerAddress'] ?? 'Assam Local';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active,
                  color: Colors.orangeAccent, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              "NEW ORDER ALERT!",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer: $customerName",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Total Amount: ₹ $amount",
              style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              "Time: $scheduledDate ($slot)",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              "Location: $address",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(orderId, "Rejected by Partner", partnerName,
                  partnerPhone);
            },
            child: const Text("REJECT",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(orderId, "Accepted - Partner on the Way",
                  partnerName, partnerPhone);
            },
            child: const Text("ACCEPT ORDER",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showOtpVerificationDialog(String orderId, String correctOtp, int orderAmount, String partnerName, String partnerPhone) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text("Enter Completion OTP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ask the customer for the 4-digit completion code shown on their screen.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (otpController.text.trim() == correctOtp) {
                Navigator.pop(ctx);
                _updateOrderStatus(orderId, "Service Completed", partnerName, partnerPhone, isCompleted: true, earnedAmount: orderAmount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ Invalid OTP! Please ask customer for correct 4-digit code."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("VERIFY & FINISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String name) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanNumber.startsWith('91') && cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }
    final Uri uri = Uri.parse(
      "https://wa.me/$cleanNumber?text=Hello%20$name,%20I%20am%20your%20service%20partner%20from%20Assam%20Local%20Service.",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitPartnerToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'experience': _experienceController.text.trim(),
        'baseRate': int.tryParse(_rateController.text.trim()) ?? 299,
        'location': _locationController.text.trim(),
        'isVerified': true,
        'rating': 5.0,
        'totalJobs': 0,
        'totalEarnings': 0,
        'isOnline': true,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Congratulations! Your Partner Profile is Live."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _updateOrderStatus(
    String bookingId,
    String newStatus,
    String partnerName,
    String partnerPhone, {
    bool isCompleted = false,
    int earnedAmount = 0,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': newStatus,
        'assignedPartnerName': partnerName,
        'partnerPhone': partnerPhone,
        'assignedPartnerId': user?.uid ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (isCompleted && user != null) {
        await FirebaseFirestore.instance
            .collection('providers')
            .doc(user.uid)
            .update({
          'totalJobs': FieldValue.increment(1),
          'totalEarnings': FieldValue.increment(earnedAmount),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCompleted
              ? "🎉 OTP Verified! ₹$earnedAmount Added to Wallet."
              : "Order status: $newStatus"),
          backgroundColor:
              isCompleted ? Colors.green : Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to update: $e"),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Service Partner Hub",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text("Please Login to access Partner Hub",
                    style: TextStyle(color: Colors.white60)),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('providers')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Colors.orangeAccent),
                    );
                  }

                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return _buildPartnerDashboard(data);
                  }

                  return _buildRegistrationForm();
                },
              ),
      ),
    );
  }

  Widget _buildPartnerDashboard(Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Partner';
    final String partnerPhone = data['phone'] ?? '7002521291';
    final String category = data['category'] ?? 'Electrician';
    final String location = data['location'] ?? 'Assam';
    final int baseRate = data['baseRate'] ?? 299;
    final double rating = (data['rating'] ?? 5.0).toDouble();
    final int jobs = data['totalJobs'] ?? 0;
    final int earnings = data['totalEarnings'] ?? 0;
    final bool isOnline = data['isOnline'] ?? true;
    final String partnerUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // 🚀 Start Realtime Popup Listener based on Online & Location Status
    _listenForNewIncomingOrders(category, name, partnerPhone, location, isOnline);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💼 Online / Offline Header Switch Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isOnline ? Colors.greenAccent.withOpacity(0.5) : Colors.redAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      child: Icon(isOnline ? Icons.verified_user : Icons.power_settings_new,
                          color: isOnline ? Colors.greenAccent : Colors.redAccent, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.check_circle,
                                  color: Colors.greenAccent, size: 18),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white54, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white10),
                const SizedBox(height: 6),

                // 🔘 Online/Offline Status Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOnline ? "DUTY STATUS: ONLINE" : "DUTY STATUS: OFFLINE",
                          style: TextStyle(
                            color: isOnline ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isOnline,
                      activeColor: Colors.greenAccent,
                      inactiveThumbColor: Colors.redAccent,
                      onChanged: (val) {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          FirebaseFirestore.instance.collection('providers').doc(uid).update({
                            'isOnline': val,
                          });
                        }
                      },
                    ),
                  ],
                ),
                const Divider(color: Colors.white10),
                const SizedBox(height: 6),

                // 💰 Realtime Earnings Tracker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Wallet Earned", "₹ $earnings", color: Colors.greenAccent),
                    _buildStatItem("Base Charge", "₹$baseRate"),
                    _buildStatItem("Jobs", "$jobs Done"),
                    _buildStatItem("Rating", "⭐ $rating"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Incoming Customer Orders",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOnline ? Colors.green : Colors.red).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOnline ? "● Live Radar" : "● Offline",
                  style: TextStyle(
                    color: isOnline ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.bedtime_outlined, color: Colors.redAccent, size: 36),
                  SizedBox(height: 8),
                  Text(
                    "You are currently Offline",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Switch toggle to Online above to receive new customer bookings.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('category', isEqualTo: category)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Colors.orangeAccent),
                    ),
                  );
                }

                final allDocs = snapshot.data?.docs ?? [];
                final partnerCity = location.toLowerCase().trim();

                final docs = allDocs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final status = d['status'] ?? '';
                  final assignedPartnerId = d['assignedPartnerId'] ?? '';
                  final custAddress = (d['customerAddress'] ?? '').toString().toLowerCase();

                  if (status == "Rejected by Partner" ||
                      status == "Service Completed" ||
                      status == "Cancelled by Customer") {
                    return false;
                  }

                  if (status.contains("Accepted")) {
                    return assignedPartnerId == partnerUid;
                  }

                  // 📍 Match order within partner's Assam district or city
                  bool matchesLocation = custAddress.contains(partnerCity) ||
                      partnerCity.contains("assam") ||
                      partnerCity.isEmpty;

                  return matchesLocation;
                }).toList();

                if (docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.radar, color: Colors.orangeAccent, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          "No active orders in $location right now",
                          style: const TextStyle(
                              color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "New incoming requests in your nearby area will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final orderData = doc.data() as Map<String, dynamic>;
                    final String orderId = doc.id;
                    final String customerName =
                        orderData['customerName'] ?? 'Customer';
                    final String custPhone =
                        orderData['customerPhone'] ?? '7002521291';
                    final String address =
                        orderData['customerAddress'] ?? 'Assam Local';
                    final int amount = orderData['totalAmount'] ?? 0;
                    final String scheduledDate =
                        orderData['scheduledDate'] ?? 'Today';
                    final String slot = orderData['scheduledSlot'] ?? '';
                    final String currentStatus =
                        orderData['status'] ?? 'Pending Partner Acceptance';
                    final String completionOtp =
                        orderData['completionOtp'] ?? '1234';
                    final bool isAccepted = currentStatus.contains("Accepted");

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAccepted
                              ? Colors.green.withOpacity(0.5)
                              : Colors.orangeAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                customerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₹ $amount",
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.white60),
                              const SizedBox(width: 6),
                              Text(
                                "$scheduledDate ($slot)",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.home_outlined,
                                  size: 14, color: Colors.white60),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 8),

                          if (isAccepted)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF25D366),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        icon: const Icon(Icons.chat,
                                            color: Colors.white, size: 16),
                                        label: const Text("WhatsApp",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        onPressed: () => _openWhatsApp(
                                            custPhone, customerName),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        icon: const Icon(Icons.message,
                                            color: Colors.white, size: 16),
                                        label: const Text("In-App Chat",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatScreen(
                                                orderId: orderId,
                                                receiverName: customerName,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                          backgroundColor: Colors.orangeAccent),
                                      icon: const Icon(Icons.call,
                                          color: Colors.black, size: 18),
                                      onPressed: () => _makeCall(custPhone),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.greenAccent),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _showOtpVerificationDialog(
                                      orderId,
                                      completionOtp,
                                      amount,
                                      name,
                                      partnerPhone,
                                    ),
                                    child: const Text(
                                      "✔ ENTER CUSTOMER OTP & FINISH JOB",
                                      style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => _updateOrderStatus(
                                        orderId,
                                        "Rejected by Partner",
                                        name,
                                        partnerPhone),
                                    child: const Text(
                                      "REJECT",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => _updateOrderStatus(
                                        orderId,
                                        "Accepted - Partner on the Way",
                                        name,
                                        partnerPhone),
                                    child: const Text(
                                      "ACCEPT",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handyman,
                      color: Colors.orangeAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Join as a Service Partner",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Get local booking orders directly across Assam.",
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Partner Details",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _nameController,
              label: "Full Name / Enterprise Name",
              hint: "e.g. Pranab Kalita",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _phoneController,
              label: "Mobile Number",
              hint: "e.g. 70025XXXXX",
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            const Text(
              "Service Category",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1E293B),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.orangeAccent),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _experienceController,
              label: "Experience",
              hint: "e.g. 5 Years Experience",
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _rateController,
              label: "Starting Service Charge (₹)",
              hint: "e.g. 299",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _locationController,
              label: "Service Area / District in Assam",
              hint: "e.g. Goalpara, Beltola, Silchar",
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: _isSaving ? null : _submitPartnerToFirestore,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "REGISTER AS PARTNER",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.orangeAccent, size: 20),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.2),
        ),
      ),
    );
  }
}
