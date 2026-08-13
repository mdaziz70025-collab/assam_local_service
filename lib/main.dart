import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  // Flutter binding aur Firebase initialize karna
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assam Local Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Auto-Login Logic: Agar user pehle se logged-in hai toh direct Home Screen par jayega
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF263238), // blueGrey[900]
              body: Center(
                child: CircularProgressIndicator(color: Colors.orangeAccent),
              ),
            );
          }
          // User Logged In
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // User Logged Out
          return const LoginScreen();
        },
      ),
      // App Routes (Navigation)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/category': (context) => const CategoryScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
