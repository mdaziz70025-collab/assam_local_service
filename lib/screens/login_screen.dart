import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  // Default selected role: Customer
  String _selectedRole = "Customer"; 

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
              const SizedBox(height: 20),
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

              // 🔴 2 Types of Login Toggle (Customer / Provider)
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
              const SizedBox(height: 25),
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
                      if (_selectedRole == "Customer") {
                        // Customer goes directly to Category Screen
                        Navigator.pushReplacementNamed(context, '/');
                      } else {
                        // Service Provider goes to Details/Registration Form Screen
                        Navigator.pushNamed(context, '/providerRegistration');
                      }
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
