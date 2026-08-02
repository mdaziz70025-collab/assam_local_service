import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = "Customer";

  void _navigateToNextScreen() {
    if (_selectedRole == "Customer") {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      Navigator.pushNamed(context, '/providerRegistration');
    }
  }

  // 🔴 1. Phone mein saved Google Accounts Dikhane Ka Modal Sheet
  void _showGoogleAccountPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.blueGrey[800],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Choose an account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                "to continue to Assam Local Service",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Divider(color: Colors.white24, height: 25),

              // Mock Saved Google Account 1
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Text("A", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                title: const Text("Abdul Aziz", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text("abdul.aziz@gmail.com", style: TextStyle(color: Colors.white60)),
                onTap: () {
                  Navigator.pop(context);
                  _performGoogleLogin("abdul.aziz@gmail.com");
                },
              ),

              // Mock Saved Google Account 2
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.lightBlueAccent,
                  child: Text("S", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                title: const Text("Service User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text("user.assam@gmail.com", style: TextStyle(color: Colors.white60)),
                onTap: () {
                  Navigator.pop(context);
                  _performGoogleLogin("user.assam@gmail.com");
                },
              ),

              const Divider(color: Colors.white24),

              // Option 2: Type Email & Password Manually
              ListTile(
                leading: const Icon(Icons.person_add_alt_1, color: Colors.orangeAccent),
                title: const Text("Use another account / Type Gmail", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showManualEmailPasswordDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔴 2. Manual Email & Password Input Dialog
  void _showManualEmailPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Google / Gmail Login", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter Gmail (e.g. example@gmail.com)",
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.email, color: Colors.orangeAccent),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter Password",
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.lock, color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () {
                if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _performGoogleLogin(emailController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email aur Password dono bharein")),
                  );
                }
              },
              child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _performGoogleLogin(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Logged in with $email as $_selectedRole!"),
      ),
    );
    _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900]!,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // App Logo
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 120,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.build_circle, size: 80, color: Colors.orangeAccent),
                ),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  "Assam Local Service",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Account Type Toggle (Customer / Service Provider)
              const Text(
                "Choose Account Type:",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRole = "Customer";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == "Customer"
                              ? Colors.orangeAccent
                              : Colors.blueGrey[800],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedRole == "Customer"
                                ? Colors.orangeAccent
                                : Colors.white24,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Customer",
                            style: TextStyle(
                              color: _selectedRole == "Customer"
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRole = "Provider";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == "Provider"
                              ? Colors.orangeAccent
                              : Colors.blueGrey[800],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedRole == "Provider"
                                ? Colors.orangeAccent
                                : Colors.white24,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Service Provider",
                            style: TextStyle(
                              color: _selectedRole == "Provider"
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 🔴 Upgraded Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                    height: 22,
                    errorBuilder: (context, error, stack) =>
                        const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
                  ),
                  label: Text(
                    "Continue with Gmail / Google",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  onPressed: _showGoogleAccountPicker,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: Colors.white54)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),

              const SizedBox(height: 20),

              // Phone Number Input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter Mobile Number",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.phone, color: Colors.orangeAccent),
                  filled: true,
                  fillColor: Colors.blueGrey[800]!,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_phoneController.text.isNotEmpty) {
                      _navigateToNextScreen();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kripya mobile number darj karein")),
                      );
                    }
                  },
                  child: Text(
                    "LOGIN AS ${_selectedRole.toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
