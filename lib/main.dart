import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Provider/map_data_provider.dart';
import 'screens/AppointmentScreen.dart';
import 'screens/bookingScreen.dart';
import 'screens/categoryScreen.dart';
import 'screens/mapsScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapDataProvider>(
          create: (_) => MapDataProvider(),
        ),
      ],
      child: MaterialApp(
        title: "Assam Multi Service",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blueGrey[900],
          colorScheme: ColorScheme.dark(
            primary: Colors.blueAccent,
            secondary: Colors.cyan[600]!,
            surface: Colors.blueGrey[900]!,
          ),
          scaffoldBackgroundColor: Colors.blueGrey[900],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        routes: {
          '/category': (context) => const CategoryScreen(),
          '/mappage': (context) => const Mappage(),
          '/bookingScreen': (context) => const BookingScreen(),
          '/appointmentScreen': (context) => const AppointmentScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Splash screen ke baad Category Screen par navigate hoga
      Navigator.of(context).pushReplacementNamed('/category');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.handyman,
            size: 100,
            color: Colors.blueAccent,
          ),
          Column(
            children: const [
              Text(
                "Assam All-in-One Services",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Electrician, Plumber, Carpenter, Barber & More",
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          )
        ],
      ),
    );
  }
}
