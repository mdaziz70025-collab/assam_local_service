import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../admin/admin_panel_screen.dart';
import '../provider/provider_registration_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _orderNotifications = true;
  bool _partnerAlerts = true;
  String _selectedLanguage = "English (ENG)";

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  bool get _isAdmin {
    final email = _currentUser?.email?.toLowerCase() ?? '';
    return email == "mdaziz70025@gmail.com";
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
      title: Text(
        lang,
        style: TextStyle(
          color: isSelected ? Colors.orangeAccent : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.orangeAccent) : null,
      onTap: () {
        setState(() => _selectedLanguage = lang);
        Navigator.pop(context);
      },
    );
  }

  void _showSavedAddressesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text("Saved Addresses", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.home, color: Colors.white70),
              title: Text("Home / Local Area", style: TextStyle(color: Colors.white)),
              subtitle: Text("Goalpara / Assam", style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
            const Divider(color: Colors.white10),
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.add_location_alt, color: Colors.orangeAccent),
              label: const Text("Add New Address", style: TextStyle(color: Colors.orangeAccent)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? "Customer";
    final userEmail = user?.email ?? "Not Logged In";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Account & Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: "Assam Local Service",
                  applicationVersion: "v1.0.4 Release",
                  applicationLegalese: "© 2026 Assam Local Service. All Rights Reserved.",
                );
              } else if (value == 'support') {
                _openWhatsAppSupport();
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orangeAccent, size: 18),
                    SizedBox(width: 10),
                    Text("About App", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'support',
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.greenAccent, size: 18),
                    SizedBox(width: 10),
                    Text("WhatsApp Support", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    SizedBox(width: 10),
                    Text("Quick Logout", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 👤 Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.orangeAccent, size: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(userEmail, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 👑 Super Admin Section (Only if Admin)
          if (_isAdmin) ...[
            _buildActionTile(
              icon: Icons.admin_panel_settings,
              title: "Super Admin Command Center",
              subtitle: "Live orders radar, verify partners & store",
              accentColor: Colors.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen())),
            ),
            const SizedBox(height: 12),
          ],

          // 🛠️ Partner Portal
          _buildActionTile(
            icon: Icons.handyman,
            title: "Service Partner Hub",
            subtitle: "Manage daily jobs, earnings & online radar",
            accentColor: Colors.orangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderRegistrationScreen())),
          ),
          const SizedBox(height: 24),

          // ⚙️ App Preferences Section
          const Text("App Preferences", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.translate,
              title: "App Language",
              trailingText: _selectedLanguage,
              onTap: _showLanguageBottomSheet,
            ),
            _buildSettingsItem(
              icon: Icons.location_city,
              title: "Saved Addresses",
              onTap: _showSavedAddressesDialog,
            ),
            SwitchListTile(
              value: _orderNotifications,
              activeColor: Colors.orangeAccent,
              title: const Text("Order Notifications", style: TextStyle(color: Colors.white, fontSize: 14)),
              secondary: const Icon(Icons.notifications_outlined, color: Colors.orangeAccent, size: 22),
              onChanged: (val) => setState(() => _orderNotifications = val),
            ),
            SwitchListTile(
              value: _partnerAlerts,
              activeColor: Colors.orangeAccent,
              title: const Text("Partner Live Radar Alerts", style: TextStyle(color: Colors.white, fontSize: 14)),
              secondary: const Icon(Icons.radar, color: Colors.orangeAccent, size: 22),
              onChanged: (val) => setState(() => _partnerAlerts = val),
            ),
          ]),
          const SizedBox(height: 24),

          // 📞 Support & Legal
          const Text("Support & Legal", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.chat_bubble_outline,
              title: "WhatsApp Help & Chat Support",
              onTap: _openWhatsAppSupport,
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: "Terms of Service & Privacy Policy",
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: "App Version",
              trailingText: "v1.0.4 Release",
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),

          // 🚪 Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444).withOpacity(0.15),
              foregroundColor: const Color(0xFFEF4444),
              elevation: 0,
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout, size: 20),
            label: const Text("LOGOUT ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            onPressed: _handleLogout,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orangeAccent, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(trailingText, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}
