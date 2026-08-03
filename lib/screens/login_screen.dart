import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package02/google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = "Customer";
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔴 Web Client ID + Explicit Scopes for Reliable Authentication
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '340401925302-44nli0ga73gq4mmlkq060mthsbbpu1lp.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  Future<void> _handleOriginalGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // 1. Purani local cache/session disconnect karo taaki stale token loop na ho
      await _googleSignIn.signOut();
      await _auth.signOut();

      // 2. Direct Native Account Picker Pop-up open karo
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User ne sign-in window dismiss kar diya
        setState(() => _isLoading = false);
        return;
      }

      // 3. Google Auth Tokens Fetch Karo
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception("Google ID Token not received. Please try again.");
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase Authentication
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Welcome ${user.displayName ?? 'User'}! Logged in as $_selectedRole.",
            ),
            backgroundColor: Colors.green,
          ),
        );
        _navigateToNextScreen();
      }
    } catch (e) {
      await _googleSignIn.signOut();
      await _auth.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Login Error: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToNextScreen() {
    if (_selectedRole == "Customer") {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      Navigator.pushNamed(context, '/providerRegistration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900]!,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(25.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        'assets/logo.png',
                        height: 120,
                        width: 120,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.build_circle,
                          size: 80,
                          color: Colors.orangeAccent,
                        ),
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

                    // Role Selection
                    const Text(
                      "Choose Account Type:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRole = "Customer"),
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
                            onTap: () =>
                                setState(() => _selectedRole = "Provider"),
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

                    // Google Sign In Button
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
                              const Icon(Icons.g_mobiledata,
                                  color: Colors.red, size: 30),
                        ),
                        label: Text(
                          "Continue with Gmail / Google",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        onPressed: _handleOriginalGoogleSignIn,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("OR",
                              style: TextStyle(color: Colors.white54)),
                        ),
                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.phone,
                            color: Colors.orangeAccent),
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
                              const SnackBar(
                                content: Text("Kripya mobile number darj karein"),
                              ),
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
