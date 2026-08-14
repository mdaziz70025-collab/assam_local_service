import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens Imports
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/mapsScreen.dart';
import 'screens/serviceBody.dart';
import 'screens/provider_registration_screen.dart';

void main() async {
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
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F172A),
              body: Center(
                child: CircularProgressIndicator(color: Colors.orangeAccent),
              ),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/category': (context) => const CategoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/mappage': (context) => const Mappage(),
        '/registerPartner': (context) => const ProviderRegistrationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/appointmentScreen') {
          final args = settings.arguments;
          String category = "Electrician";

          if (args is String) {
            category = args;
          } else if (args is Map<String, dynamic> && args['category'] != null) {
            category = args['category'];
          }

          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: const Color(0xFF0F172A),
              appBar: AppBar(
                title: Text("$category Rate List"),
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              body: ServiceBody(serviceCategory: category),
            ),
          );
        }
        return null;
      },
    );
  }
}
