import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'order_tracking_screen.dart';
import 'chat_screen.dart';

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

  // 🌐 Multilingual State (en, as, bn)
  String _selectedLang = 'en';

  final Map<String, Map<String, String>> _langStrings = {
    'en': {
      'explore': 'Explore',
      'bookings': 'Bookings',
      'account': 'Account',
      'offer': 'Get Flat 20% OFF\nOn Doorstep Services',
      'select_service': 'Select A Service',
      'search': "Search 'Electrician', 'AC', 'Plumber'...",
      'otp_badge': "Completion OTP:",
    },
    'as': {
      'explore': 'অন্বেষণ',
      'bookings': 'অৰ্ডাৰসমূহ',
      'account': 'একাউণ্ট',
      'offer': 'ঘৰুৱা সেৱাত পাওক\n২০% ৰেহাই',
      'select_service': 'সেৱা বাছক',
      'search': 'ইলেক্ট্ৰিচিয়ান, প্লাম্বাৰ সন্ধান কৰক...',
      'otp_badge': 'সমাপ্তি অ’টিপি:',
    },
    'bn': {
      'explore': 'সার্ভিস',
      'bookings': 'অর্ডার',
      'account': 'অ্যাকাউন্ট',
      'offer': 'হোম সার্ভিসে পান\n২০% ডিসকাউন্ট',
      'select_service': 'সার্ভিস বেছে নিন',
      'search': 'ইলেকট্রিশিয়ান, প্লাম্বার খুঁজুন...',
      'otp_badge': 'সমাপ্তি ওটিপি:',
    }
  };

  final List<String> _popularLocalities = [
    "Guwahati (Kamrup Metro)",
    "Dispur, Assam",
    "Beltola / Six Mile, Guwahati",
    "Jalukbari / Maligaon, Guwahati",
    "Silchar (Cachar)",
    "Dibrugarh Town",
    "Jorhat Central",
    "Nagaon Market",
    "Tezpur (Sonitpur)",
    "Tinsukia Town",
    "Bongaigaon City",
    "Barpeta Town / Road",
    "Dhubri Town",
    "Goalpara Town",
    "Karimganj Town",
    "Hailakandi Town",
    "Sivasagar Town",
    "Golaghat Town",
    "North Lakhimpur",
    "Dhemaji Town",
    "Kokrajhar (BTR)",
    "Nalbari Town",
    "Morigaon Town",
    "Hojai Town",
    "Diphu (Karbi Anglong)",
    "Haflong (Dima Hasao)",
    "Mangaldai (Darrang)",
    "Udalguri (BTR)",
    "Chirang / Kajalgaon",
    "Baksa / Mushalpur",
    "Biswanath Chariali",
    "Charaideo / Sonari",
    "South Salmara",
    "Majuli River Island",
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveLocation();
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
      "https://wa.me/$cleanNumber?text=Hello%20$partnerName,%20I%20have%20booked%20your%20service%20via%20Assam%20Local%20Service.",
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

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

  void _openLocationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Where do you want your service?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.my_location, color: Colors.black),
                label: const Text(
                  "Detect Current GPS Location",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _fetchLiveLocation();
                },
              ),
            ),
          ],
        ),
      ),
    );
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
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_filled),
              label: t['explore']!,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              label: t['bookings']!,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: t['account']!,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌐 Top Bar with Language Selector Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _openLocationBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.orangeAccent, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _userLocation,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Language Switch Menu
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

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
            ),
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

          // Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9900), Color(0xFFFF5E62)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              t['offer']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            t['select_service']!,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, i) {
              final cat = allCategories[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/appointmentScreen',
                    arguments: cat["name"],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (cat["color"] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat["icon"], color: cat["color"], size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat["name"],
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= 📅 TAB 2: LIVE BOOKINGS WITH OTP & CHAT =================
  Widget _buildBookingsTab(Map<String, String> t) {
    final currentUserId = user?.uid;
    if (currentUserId == null) {
      return const Center(child: Text("Please log in.", style: TextStyle(color: Colors.white60)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text("No Active Bookings", style: TextStyle(color: Colors.white60, fontSize: 16)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final category = data['category'] ?? "Service";
            final totalAmount = data['totalAmount'] ?? 0;
            final date = data['scheduledDate'] ?? "Today";
            final slot = data['scheduledSlot'] ?? "";
            final status = data['status'] ?? "Partner Assigned";
            final partnerName = data['assignedPartnerName'] ?? "Aziz";
            final partnerPhone = data['partnerPhone'] ?? "7002521291";
            final completionOtp = data['completionOtp'] ?? "1234";
            final bool isAccepted = status.contains("Accepted");
            final bool isCompleted = status.contains("Completed");

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAccepted ? Colors.green.withOpacity(0.5) : Colors.orangeAccent.withOpacity(0.3),
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
                          color: isAccepted ? Colors.green.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: isAccepted ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 🔐 4-Digit Completion OTP Banner
                  if (!isCompleted)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t['otp_badge']!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            completionOtp,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 4),
                          ),
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

                  if (isAccepted) ...[
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    orderId: docs[i].id,
                                    receiverName: partnerName,
                                  ),
                                ),
                              );
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orangeAccent,
                  child: const Icon(Icons.person, size: 28, color: Colors.black),
                ),
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
