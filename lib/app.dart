import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/booking/category_screen.dart';
import 'screens/booking/service_body.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/maps/maps_screen.dart';
import 'screens/provider/provider_registration_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
          String category = 'Electrician';

          if (args is String) {
            category = args;
          } else if (args is Map<String, dynamic> && args['category'] != null) {
            category = args['category'] as String;
          }

          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              appBar: AppBar(
                title: Text('$category Rate List'),
                backgroundColor: AppColors.cardBg,
                foregroundColor: AppColors.textPrimary,
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
