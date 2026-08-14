import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool isDarkMode = true;
  String selectedLanguage = 'English';

  // Logout Handler
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Log Out",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to log out of Assam Local Service?",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logout failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Edit Profile Bottom Sheet
  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: user?.displayName ?? "");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: const TextStyle(color: Colors.orangeAccent),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    await user?.updateDisplayName(nameController.text.trim());
                    setState(() {});
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generic Information Dialog for Bookings & Addresses
  void _showInfoSheet(String title, String emptyMessage, IconData icon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.orangeAccent),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Help & Support Sheet
  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.support_agent, size: 50, color: Colors.orangeAccent),
            const SizedBox(height: 12),
            Text(
              "Assam Local Service Desk",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.orangeAccent),
              title: Text(
                "support@assamlocalservice.com",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.orangeAccent),
              title: Text(
                "+91 70025 XXXXX (Mon-Sat 9AM-7PM)",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "My Account",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.orangeAccent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 👤 Profile Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.orangeAccent,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, size: 40, color: Colors.black)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showEditProfileSheet,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Assam Local User",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? user?.phoneNumber ?? "No Email Associated",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ⚡ Quick Stats Row
            Row(
              children: [
                _buildStatCard("Bookings", "0", Icons.calendar_today, cardColor),
                const SizedBox(width: 12),
                _buildStatCard("Active", "0", Icons.bolt, cardColor),
                const SizedBox(width: 12),
                _buildStatCard("Offers", "3", Icons.local_offer, cardColor),
              ],
            ),
            const SizedBox(height: 20),

            // 🛠️ Services Section
            _buildSectionHeader("MY SERVICES"),
            _buildCardGroup(
              cardColor,
              [
                _buildModernTile(
                  icon: Icons.history,
                  title: "My Service Bookings",
                  subtitle: "View current & past bookings",
                  onTap: () => _showInfoSheet(
                    "Service Bookings",
                    "You have no active or completed bookings yet.",
                    Icons.history,
                  ),
                ),
                _buildDivider(),
                _buildModernTile(
                  icon: Icons.location_on_outlined,
                  title: "Saved Addresses",
                  subtitle: "Manage service location points",
                  onTap: () => _showInfoSheet(
                    "Saved Addresses",
                    "No addresses saved. Addresses will appear once you place an order.",
                    Icons.location_on_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ⚙️ App Preferences Section
            _buildSectionHeader("PREFERENCES"),
            _buildCardGroup(
              cardColor,
              [
                _buildModernTile(
                  icon: Icons.language,
                  title: "Language / Bhasha",
                  subtitle: selectedLanguage,
                  onTap: _showLanguageDialog,
                ),
                _buildDivider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dark_mode_outlined, color: Colors.orangeAccent),
                  ),
                  title: Text(
                    "Dark Theme",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Switch(
                    value: isDarkMode,
                    activeColor: Colors.orangeAccent,
                    onChanged: (val) => setState(() => isDarkMode = val),
                  ),
                ),
                _buildDivider(),
                _buildModernTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  subtitle: "24x7 customer assistance",
                  onTap: _showHelpSheet,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🚪 Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                label: const Text(
                  "LOG OUT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: _handleLogout,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper: Stat Card
  Widget _buildStatCard(String label, String count, IconData icon, Color cardColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.orangeAccent),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Section Header
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: isDarkMode ? Colors.white38 : Colors.black45,
          ),
        ),
      ),
    );
  }

  // Helper: Card Group Container
  Widget _buildCardGroup(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Helper: Modern ListTile
  Widget _buildModernTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.orangeAccent, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black54,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: isDarkMode ? Colors.white38 : Colors.black38,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60,
      color: isDarkMode ? Colors.white10 : Colors.black12,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Select Language",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                "English",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
              trailing: selectedLanguage == 'English'
                  ? const Icon(Icons.check_circle, color: Colors.orangeAccent)
                  : null,
              onTap: () {
                setState(() => selectedLanguage = 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                "অসমীয়া (Assamese)",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
              trailing: selectedLanguage == 'অসমীয়া'
                  ? const Icon(Icons.check_circle, color: Colors.orangeAccent)
                  : null,
              onTap: () {
                setState(() => selectedLanguage = 'অসমীয়া');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
