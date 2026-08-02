import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/map_data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/category_screen.dart';
import 'screens/mapsScreen.dart';
import 'screens/appointmentScreen.dart';
import 'screens/bookingScreen.dart';

void main() {
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
          '/': (context) => const CategoryScreen(),
          '/mappage': (context) => const Mappage(),
          '/appointmentScreen': (context) => const AppointmentScreen(),
          '/bookingScreen': (context) => const BookingScreen(),
        },
      ),
    );
  }
}
