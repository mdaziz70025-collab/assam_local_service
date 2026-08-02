import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/barber_data_from_map_provider.dart';
import 'Provider/map_data_provider.dart';
import 'screens/mapsScreen.dart';
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
        ChangeNotifierProvider<BarberDataFromMapProvider>(
          create: (_) => BarberDataFromMapProvider()..loadData(),
        ),
        ChangeNotifierProvider<MapDataProvider>(
          create: (_) => MapDataProvider()..loadMapData(),
        ),
      ],
      child: MaterialApp(
        title: 'Assam Local Service',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const Mappage(),
          '/mappage': (context) => const Mappage(),
          '/bookingScreen': (context) => const BookingScreen(),
        },
      ),
    );
  }
}
