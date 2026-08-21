import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../admin/admin_panel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;
  String _userLocation = "Detecting Assam location...";
  String _searchQuery = "";
  bool _isLocating = false;

  String _selectedLang = 'en';

  bool get _isAdminUser {
    if (user == null) return false;
    final email = user!.email?.toLowerCase() ?? '';
    return email == "mdaziz70025@gmail.com";
  }

  final Map<String, Map<String, String>> _langStrings = {
    'en': {
      'explore': 'Explore',
      'bookings': 'Bookings',
      'account': 'Account',
      'offer': 'Get Flat 20% OFF\nOn Doorstep Services',
      'select_service': 'Select A Service',
      'top_partners': '⭐ Top Verified Partners in Assam',
      'store_title': '🛍️ Essential Parts & Marketing Deals',
      'trust_title': '🛡️ Assam Local Service Guarantee',
      'search': "Search 'Electrician', 'AC', 'Plumber'...",
      'otp_badge': "Completion OTP:",
    },
    'as': {
      'explore': 'অন্বেষণ',
      'bookings': 'অৰ্ডাৰসমূহ',
      'account': 'একাউণ্ট',
      'offer': 'ঘৰুৱা সেৱাত পাওক\n২০% ৰেহাই',
      'select_service': 'সেৱা বাছক',
      'top_partners': '⭐ অসমৰ শীৰ্ষ প্ৰমাণিত অংশীদাৰ',
      'store_title': '🛍️ প্ৰয়োজনীয় সামগ্ৰী আৰু সামগ্ৰীৰ দোকান',
      'trust_title': '🛡️ নিশ্চিত আৰু বিশ্বাসযোগ্য সেৱা',
      'search': 'ইলেক্ট্ৰিচিয়ান, প্লাম্বাৰ সন্ধান কৰক...',
      'otp_badge': 'সমাপ্তি অ’টিপি:',
    },
    'bn': {
      'explore': 'সার্ভিস',
      'bookings': 'অর্ডার',
      'account': 'অ্যাকাউন্ট',
      'offer': 'হোম সার্ভিসে পান\n২০% ডিসকাউন্ট',
      'select_service': 'সার্ভিস বেছে নিন',
      'top_partners': '⭐ শীর্ষ ভেরিফাইড পার্টনার্স',
      'store_title': '🛍️ প্রয়োজনীয় পার্টস ও বিশেষ ডিল',
      'trust_title': '🛡️ ১০০% বিশ্বস্ত ও নিরাপদ সার্ভিস',
      'search': 'ইলেকট্রিশিয়ান, প্লাম্বার খুঁজুন...',
      'otp_badge': 'সমাপ্তি ওটিপি:',
    }
  };

  @override
  void initState() {
    super.initState();
    _fetchLiveLocation();
  }

  void _showRatingDialog(String bookingId, String partnerId, String partnerName) {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Rate $partnerName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How was your service experience?", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reviewController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write a short review (optional)...",
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Skip", style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
                  'customerRating': rating,
                  'customerReview': reviewController.text.trim(),
                  'isReviewed': true,
                });
                if (partnerId.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('providers').doc(partnerId).update({
                    'rating': rating.toDouble(),
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you for your review! ⭐"), backgroundColor: Colors.green),
                );
              },
              child: const Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 🔄 Reschedule Booking Modal
  void _openRescheduleDialog(String bookingId) {
    String newDate = "Tomorrow";
    String newSlot = "11:00 AM - 01:00 PM";
    final days = ["Tomorrow", "Day After", "Today"];
    final slots = [
      "09:00 AM - 11:00 AM",
      "11:00 AM - 01:00 PM",
      "02:00 PM - 04:00 PM",
      "04:00 PM - 06:00 PM",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Reschedule Service Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              Row(
                children: days.map((d) {
                  final isSel = newDate == d;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setSheetState(() => newDate = d),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? Colors.orangeAccent : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(d, textAlign: TextAlign.center, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: slots.map((s) {
                  final isSel = newSlot == s;
                  return ChoiceChip(
                    label: Text(s, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontSize: 11)),
                    selected: isSel,
                    selectedColor: Colors.orangeAccent,
                    backgroundColor: const Color(0xFF0F172A),
                    onSelected: (val) => setSheetState(() => newSlot = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
                      'scheduledDate': newDate,
                      'scheduledSlot': newSlot,
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Booking rescheduled to $newDate ($newSlot) ✅"), backgroundColor: Colors.green),
                    );
                  },
                  child: const Text("CONFIRM RESCHEDULE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ❌ Cancel Booking Confirmation
  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Cancel Booking?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to cancel this booking request?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'Cancelled by Customer',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking has been cancelled."), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String partnerName) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanNumber.startsWith('91') && cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }
    final Uri uri = Uri.parse(
      "https://wa.me/$cleanNumber?text=Hello%20$partnerName,%20I%20want%20to%20inquire%20about%20your%20service.",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _fetchLiveLocation() async {
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _userLocation = "Guwahati, Assam (Turn on GPS)";
          _isLocating = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _userLocation = "Guwahati, Assam (Permission Denied)";
            _isLocating = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String villageOrStreet = place.subLocality != null && place.subLocality!.isNotEmpty
            ? place.subLocality!
            : (place.street != null && place.street!.isNotEmpty ? place.street! : place.name ?? "");

        String cityOrDistrict = place.locality != null && place.locality!.isNotEmpty
            ? place.locality!
            : (place.subAdministrativeArea ?? "Assam");

        String postalCode = place.postalCode != null ? " - ${place.postalCode}" : "";

        setState(() {
          if (villageOrStreet.isNotEmpty && villageOrStreet != cityOrDistrict) {
            _userLocation = "$villageOrStreet, $cityOrDistrict$postalCode";
          } else {
            _userLocation = "$cityOrDistrict, Assam$postalCode";
          }
          _isLocating = false;
        });
      }
    } catch (e) {
      setState(() {
        _userLocation = "Guwahati, Assam";
        _isLocating = false;
      });
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _langStrings[_selectedLang]!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(t),
            _buildBookingsTab(t),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: Colors.orangeAccent,
          unselectedItemColor: Colors.white54,
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: t['explore']!),
            BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_outlined), label: t['bookings']!),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: t['account']!),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(Map<String, String> t) {
    final List<Map<String, dynamic>> allCategories = [
      {"name": "Electrician", "icon": Icons.electrical_services, "color": Colors.amber},
      {"name": "Plumber", "icon": Icons.plumbing, "color": Colors.cyan},
      {"name": "AC Repair", "icon": Icons.ac_unit, "color": Colors.blueAccent},
      {"name": "Cleaning", "icon": Icons.cleaning_services, "color": Colors.greenAccent},
      {"name": "Painter", "icon": Icons.format_paint, "color": Colors.pinkAccent},
      {"name": "Carpenter", "icon": Icons.handyman, "color": Colors.orange},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.orangeAccent, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(_userLocation, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLang,
                    dropdownColor: const Color(0xFF1E293B),
                    icon: const Icon(Icons.language, color: Colors.orangeAccent, size: 18),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text("ENG")),
                      DropdownMenuItem(value: 'as', child: Text("অসমীয়া")),
                      DropdownMenuItem(value: 'bn', child: Text("বাংলা")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLang = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: Colors.orangeAccent),
                hintText: t['search']!,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF9900), Color(0xFFFF5E62)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(t['offer']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
          ),
          const SizedBox(height: 20),

          Text(t['select_service']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95),
            itemBuilder: (context, i) {
              final cat = allCategories[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/appointmentScreen', arguments: cat["name"]);
                },
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: (cat["color"] as Color).withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(cat["icon"], color: cat["color"], size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(cat["name"], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(t['top_partners']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('providers').where('isVerified', isEqualTo: true).limit(5).snapshots(),
            builder: (context, snapshot) {
              final partners = snapshot.data?.docs ?? [];

              if (partners.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
                  child: const Row(
                    children: [
                      Icon(Icons.handyman, color: Colors.orangeAccent),
                      SizedBox(width: 10),
                      Text("Aziz (Electrician) • Goalpara (⭐ 5.0)", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                );
              }

              return SizedBox(
                height: 135,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: partners.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final p = partners[idx].data() as Map<String, dynamic>;
                    final pName = p['name'] ?? 'Partner';
                    final pCat = p['category'] ?? 'Service';
                    final pLoc = p['location'] ?? 'Assam';
                    final pPhone = p['phone'] ?? '7002521291';
                    final double pRating = (p['rating'] ?? 5.0).toDouble();

                    return Container(
                      width: 220,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                                child: const Icon(Icons.person, color: Colors.orangeAccent, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                                    Text(pCat, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white38, size: 12),
                              const SizedBox(width: 4),
                              Expanded(child: Text(pLoc, style: const TextStyle(color: Colors.white60, fontSize: 11), overflow: TextOverflow.ellipsis)),
                              Text("⭐ $pRating", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _openWhatsApp(pPhone, pName),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(6)),
                                    child: const Center(child: Text("WhatsApp", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _makeCall(pPhone),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(6)),
                                    child: const Center(child: Text("Call", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(t['store_title']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').where('isAvailable', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              final products = snapshot.data?.docs ?? [];

              if (products.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text("Admin will list parts & marketing deals here.", style: TextStyle(color: Colors.white38, fontSize: 12))),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, i) {
                  final prod = products[i].data() as Map<String, dynamic>;
                  final name = prod['name'] ?? 'Part';
                  final price = prod['price'] ?? 0;
                  final oldPrice = prod['oldPrice'] ?? 0;
                  final tag = prod['tag'] ?? 'Best Seller';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: Text(tag, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text("₹$price", style: const TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                            if (oldPrice > 0) ...[
                              const SizedBox(width: 6),
                              Text("₹$oldPrice", style: const TextStyle(color: Colors.white38, fontSize: 11, decoration: TextDecoration.lineThrough)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: EdgeInsets.zero),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Inquiry sent for $name"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                              );
                            },
                            child: const Text("ORDER PART", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
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

  Widget _buildBookingsTab(Map<String, String> t) {
    final currentUserId = user?.uid;
    if (currentUserId == null) {
      return const Center(child: Text("Please log in.", style: TextStyle(color: Colors.white60)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No Active Bookings", style: TextStyle(color: Colors.white60, fontSize: 16)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final bookingId = docs[i].id;
            final category = data['category'] ?? "Service";
            final totalAmount = data['totalAmount'] ?? 0;
            final date = data['scheduledDate'] ?? "Today";
            final slot = data['scheduledSlot'] ?? "";
            final status = data['status'] ?? "Pending Partner Acceptance";
            final partnerName = data['assignedPartnerName'] ?? "Aziz";
            final partnerPhone = data['partnerPhone'] ?? "7002521291";
            final partnerId = data['assignedPartnerId'] ?? "";
            final completionOtp = data['completionOtp'] ?? "1234";
            final bool isAccepted = status.contains("Accepted");
            final bool isCompleted = status.contains("Completed");
            final bool isCancelled = status.contains("Cancelled");
            final bool isReviewed = data['isReviewed'] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCancelled
                      ? Colors.redAccent.withOpacity(0.4)
                      : (isAccepted ? Colors.green.withOpacity(0.5) : Colors.orangeAccent.withOpacity(0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCancelled
                              ? Colors.red.withOpacity(0.2)
                              : (isAccepted ? Colors.green.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: isCancelled ? Colors.redAccent : (isAccepted ? Colors.greenAccent : Colors.orangeAccent),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (!isCompleted && !isCancelled)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t['otp_badge']!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(completionOtp, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 4)),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.orangeAccent),
                      const SizedBox(width: 6),
                      Text("$date ($slot)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const Spacer(),
                      Text("₹ $totalAmount", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),

                  // 🔄 Cancel & Reschedule Action Buttons
                  if (!isCompleted && !isCancelled) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            onPressed: () => _openRescheduleDialog(bookingId),
                            child: const Text("Reschedule", style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            onPressed: () => _cancelBooking(bookingId),
                            child: const Text("Cancel Booking", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (isCompleted && !isReviewed) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        icon: const Icon(Icons.star, color: Colors.black, size: 16),
                        label: const Text("Rate & Review Partner", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () => _showRatingDialog(bookingId, partnerId, partnerName),
                      ),
                    ),
                  ],

                  if (isAccepted && !isCancelled) ...[
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                            icon: const Icon(Icons.chat, color: Colors.white, size: 16),
                            label: const Text("WhatsApp", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => _openWhatsApp(partnerPhone, partnerName),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                            icon: const Icon(Icons.message, color: Colors.white, size: 16),
                            label: const Text("In-App Chat", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(orderId: docs[i].id, receiverName: partnerName)));
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          style: IconButton.styleFrom(backgroundColor: Colors.orangeAccent),
                          icon: const Icon(Icons.call, color: Colors.black, size: 18),
                          onPressed: () => _makeCall(partnerPhone),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, backgroundColor: Colors.orangeAccent, child: Icon(Icons.person, size: 28, color: Colors.black)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? "Md Aziz", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? user?.phoneNumber ?? "", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isAdminUser)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded, color: Colors.black),
                title: const Text("Super Admin Command Center", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("Manage Store, Live Orders & Partners", style: TextStyle(color: Colors.black87, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen())),
              ),
            ),

          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: const Color(0xFF1E293B),
            leading: const Icon(Icons.handyman_outlined, color: Colors.orangeAccent),
            title: const Text("Register as Service Partner", style: TextStyle(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
            onTap: () => Navigator.pushNamed(context, '/registerPartner'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _handleSignOut(context),
            ),
          ),
        ],
      ),
    );
  }
}
