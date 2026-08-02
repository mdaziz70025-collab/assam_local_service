import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 👈 Firebase Core Import
import 'package:provider/provider.dart';
import 'Provider/map_data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/provider_registration_screen.dart';
import 'screens/category_screen.dart';
import 'screens/mapsScreen.dart';
import 'screens/appointmentScreen.dart';
import 'screens/bookingScreen.dart';

void main() async {
  // Flutter engine initialization
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔴 Genuine Firebase Initialization
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
        // App khulte hi Login Screen dikhegi
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/providerRegistration': (context) => const ProviderRegistrationScreen(),
          '/': (context) => const CategoryScreen(),
          '/mappage': (context) => const Mappage(),
          '/appointmentScreen': (context) => const AppointmentScreen(),
          '/bookingScreen': (context) => const BookingScreen(),
        },
      ),
    );
  }
}
