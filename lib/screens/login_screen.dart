import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // Correct Web Client ID from google-services.json (client_type: 3)
  final String _webClientId =
      '340401925302-44nli0ga73gq4mmlkq060mthsbbpu1lp.apps.googleusercontent.com';

  // 1️⃣ Passwordless Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _webClientId,
      );

      await googleSignIn.signOut(); // Clear previous session
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Login Failed: ${error.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2️⃣ Passwordless Facebook Login
  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (result.status == LoginStatus.cancelled) {
        if (mounted) setState(() => _isLoading = false);
        return;
      } else {
        throw Exception(result.message);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Facebook Login Failed: ${error.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 80,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              const Text(
                "Assam Local Service",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Find local services near you easily",
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 48),

              // Loader / Login Buttons
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.orangeAccent)
              else ...[
                // Google Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.g_mobiledata, size: 30, color: Colors.blue),
                    ),
                    label: const Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _signInWithGoogle,
                  ),
                ),
                const SizedBox(height: 16),

                // Facebook Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.facebook, size: 28),
                    label: const Text(
                      "Continue with Facebook",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _signInWithFacebook,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
