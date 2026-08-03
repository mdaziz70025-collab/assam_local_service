import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Provider/map_data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/provider_registration_screen.dart';
import 'screens/category_screen.dart';
import 'screens/mapsScreen.dart';
import 'screens/appointmentScreen.dart';
import 'screens/bookingScreen.dart';
import 'screens/profile_screen.dart'; // 👈 Profile Screen Import Added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapDataProvider>(
          create: (_) => MapDataProvider()..loadData(),
        ),
      ],
      child: MaterialApp(
        title: 'Assam Local Service',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/providerRegistration': (context) => const ProviderRegistrationScreen(),
          '/': (context) => const CategoryScreen(),
          '/mappage': (context) => const Mappage(),
          '/appointmentScreen': (context) => const AppointmentScreen(),
          '/bookingScreen': (context) => const BookingScreen(),
          '/profile': (context) => const ProfileScreen(), // 👈 Added Profile Route
        },
      ),
    );
  }
}
