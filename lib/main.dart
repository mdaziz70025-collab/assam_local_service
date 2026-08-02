import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        initialRoute: '/',
        routes: {
          '/': (context) => Mappage(),
          '/mappage': (context) => Mappage(),
          '/bookingScreen': (context) => const BookingScreen(),
        },
      ),
    );
  }
}
