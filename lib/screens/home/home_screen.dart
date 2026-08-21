import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../booking/category_screen.dart';
import '../booking/order_tracking_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeExploreTab(),
    const OrderTrackingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavPill(0, Icons.explore_outlined, Icons.explore, "Explore"),
            _buildNavPill(1, Icons.calendar_today_outlined, Icons.calendar_month, "Bookings"),
            _buildNavPill(2, Icons.person_outline, Icons.person, "Account"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavPill(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orangeAccent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: Colors.orangeAccent.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? Colors.orangeAccent : Colors.white60, size: 20),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeExploreTab extends StatefulWidget {
  const HomeExploreTab({Key? key}) : super(key: key);

  @override
  State<HomeExploreTab> createState() => _HomeExploreTabState();
}

class _HomeExploreTabState extends State<HomeExploreTab> {
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;
  String _selectedLanguage = "English (ENG)";

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Electrician', 'icon': Icons.bolt, 'color': Colors.amber},
    {'title': 'Plumber', 'icon': Icons.plumbing, 'color': Colors.cyan},
    {'title': 'AC Repair', 'icon': Icons.ac_unit, 'color': Colors.lightBlue},
    {'title': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.teal},
    {'title': 'Painter', 'icon': Icons.format_paint, 'color': Colors.purpleAccent},
    {'title': 'Carpenter', 'icon': Icons.handyman, 'color': Colors.orangeAccent},
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _bannerIndex = (_bannerIndex + 1) % 2;
        _bannerController.animateToPage(_bannerIndex, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _openWhatsAppSupport() async {
    final uri = Uri.parse("https://wa.me/917002521291?text=Hello%20Assam%20Local%20Service%20Support,%20I%20need%20help.");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Language / ভাষা বাছক",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption("English (ENG)"),
            _buildLanguageOption("অসমীয়া (Assamese)"),
            _buildLanguageOption("বাংলা (Bengali)"),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String lang) {
    final isSelected = _selectedLanguage == lang;
    return ListTile(
      title: Text(lang, style: TextStyle(color: isSelected ? Colors.orangeAccent : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.orangeAccent) : null,
      onTap: () {
        setState(() => _selectedLanguage = lang);
        Navigator.pop(context);
      },
    );
  }

  void _openWhatsApp(String phone, String name) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse("https://wa.me/91$cleanPhone?text=Hello%20$name,%20I%20want%20to%20book%20a%20service.");
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 📍 Top Location Bar + 3-Dot Quick Action Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.orangeAccent, size: 16),
                    SizedBox(width: 6),
                    Text("Goalpara, Assam", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
                  ],
                ),
              ),

              // 🔘 3-Dot Menu Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.orangeAccent, size: 20),
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  onSelected: (value) {
                    if (value == 'settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    } else if (value == 'language') {
                      _showLanguageBottomSheet();
                    } else if (value == 'help') {
                      _openWhatsAppSupport();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, color: Colors.orangeAccent, size: 18),
                          SizedBox(width: 10),
                          Text("Settings & Account", style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'language',
                      child: Row(
                        children: [
                          Icon(Icons.translate, color: Colors.cyanAccent, size: 18),
                          SizedBox(width: 10),
                          Text("Language / ভাষা", style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'help',
                      child: Row(
                        children: [
                          Icon(Icons.support_agent, color: Colors.greenAccent, size: 18),
                          SizedBox(width: 10),
                          Text("WhatsApp Support", style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔍 Floating Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.orangeAccent, size: 20),
                SizedBox(width: 12),
                Text("Search 'Electrician', 'Plumber', 'AC'...", style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 🎁 Animated Promo Carousel
          SizedBox(
            height: 125,
            child: PageView(
              controller: _bannerController,
              onPageChanged: (i) => setState(() => _bannerIndex = i),
              children: [
                _buildPromoBanner("Get Flat 20% OFF", "On Doorstep Home Services in Assam", Colors.orangeAccent),
                _buildPromoBanner("Verified Mistri & AC Repair", "Instant OTP Protected Completion", Colors.cyanAccent),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ⚡ Modern 3-Column Service Grid
          const Text("Select a Service", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(categoryName: cat['title']))),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: (cat['color'] as Color).withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat['icon'], color: cat['color'], size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(cat['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // ⭐ Top Verified Partners List
          const Text("⭐ Top Verified Partners in Assam", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('providers').where('isVerified', isEqualTo: true).limit(4).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No verified partners nearby right now.", style: TextStyle(color: Colors.white38, fontSize: 12)));
              }
              final partners = snapshot.data!.docs;
              return SizedBox(
                height: 135,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: partners.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final p = partners[index].data() as Map<String, dynamic>;
                    final name = p['name'] ?? 'Partner';
                    final category = p['category'] ?? 'Service';
                    final phone = p['phone'] ?? '7002521291';
                    final location = p['location'] ?? 'Assam';

                    return Container(
                      width: 180,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
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
                                child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("$category • $location", style: const TextStyle(color: Colors.white60, fontSize: 11), overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  onPressed: () => _openWhatsApp(phone, name),
                                  child: const Text("WhatsApp", style: TextStyle(fontSize: 11, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _makeCall(phone),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.call, size: 16, color: Colors.black),
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
        ],
      ),
    );
  }

  Widget _buildPromoBanner(String title, String subtitle, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF1E293B), accentColor.withOpacity(0.2)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.local_offer_outlined, color: accentColor, size: 36),
        ],
      ),
    );
  }
}
