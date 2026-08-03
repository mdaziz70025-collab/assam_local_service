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

  Future<void> _handleLogout() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.orangeAccent,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 50, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? "Assam Local User",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? user?.phoneNumber ?? "No contact details",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
            const SizedBox(height: 10),
            _buildSettingTile(
              icon: Icons.location_on,
              title: "Saved Addresses",
              subtitle: "Manage home & work addresses",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: "Language / Bhasha",
              subtitle: selectedLanguage,
              onTap: _showLanguageDialog,
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.orangeAccent),
              title: Text(
                "Dark Mode",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Switch(
                value: isDarkMode,
                activeColor: Colors.orangeAccent,
                onChanged: (val) => setState(() => isDarkMode = val),
              ),
            ),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "Contact Assam Local Service desk",
              onTap: () {},
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "LOG OUT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onPressed: _handleLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orangeAccent),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black54,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkMode ? Colors.white38 : Colors.black38,
      ),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.blueGrey[800] : Colors.white,
        title: Text(
          "Select Language",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                "English",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              trailing: selectedLanguage == 'English'
                  ? const Icon(Icons.check, color: Colors.orangeAccent)
                  : null,
              onTap: () {
                setState(() => selectedLanguage = 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                "অসমীয়া (Assamese)",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              trailing: selectedLanguage == 'অসমীয়া'
                  ? const Icon(Icons.check, color: Colors.orangeAccent)
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
