import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  /// Change this to your production package-friendly admin check.
  /// Prefer storing role: 'admin' in Firestore users collection.
  static const List<String> adminEmails = [
    'mdaziz70025@gmail.com',
  ];

  static const String googleWebClientId =
      '340401925302-44nli0ga73gq4mmlkq060mthsbbpu1lp.apps.googleusercontent.com';

  static const String appName = 'Assam Local Service';
  static const String supportEmail = 'support@assamlocalservice.com';
  static const String supportPhone = '+91 70025 XXXXX';

  static const List<String> serviceCategories = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Barber / Salon',
    'Mason (Mistri)',
    'Home Cleaning',
    'Painter',
    'AC Repair',
  ];

  static const List<Map<String, dynamic>> categoryMeta = [
    {'name': 'Electrician', 'icon': Icons.electrical_services, 'color': Colors.orangeAccent},
    {'name': 'Plumber', 'icon': Icons.plumbing, 'color': Colors.cyan},
    {'name': 'Carpenter', 'icon': Icons.carpenter, 'color': Colors.brown},
    {'name': 'Barber / Salon', 'icon': Icons.content_cut, 'color': Colors.pinkAccent},
    {'name': 'Mason (Mistri)', 'icon': Icons.construction, 'color': Colors.grey},
    {'name': 'Home Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.green},
    {'name': 'Painter', 'icon': Icons.format_paint, 'color': Colors.purpleAccent},
    {'name': 'AC Repair', 'icon': Icons.handyman, 'color': Colors.teal},
  ];

  /// Rate list used by booking screen
  static const Map<String, Map<String, int>> masterServices = {
    'Electrician': {
      'Switchboard Repair / Replace': 150,
      'Ceiling Fan Installation': 200,
      'Full Wiring Checkup': 350,
      'Inverter & Battery Setup': 500,
      'MCB / Fuse Box Repair': 250,
    },
    'Plumber': {
      'Pipe Leakage Repair': 200,
      'Tap / Faucet Fitting': 150,
      'Water Tank Cleaning': 600,
      'Basin & Sink Installation': 400,
      'Drainage Blockage Clearing': 350,
    },
    'Carpenter': {
      'Door Lock Repair / Installation': 200,
      'Bed / Furniture Repair': 450,
      'Modular Kitchen Fitting': 800,
      'Window Latch & Hinges Fix': 150,
    },
    'Barber / Salon': {
      'Men Haircut': 100,
      'Beard Grooming & Shape': 80,
      'Face Cleansing & Facial': 300,
      'Hair Color & Treatment': 250,
    },
    'Mason (Mistri)': {
      'Tile Fitting Work (per sq ft)': 40,
      'Wall Plaster Touchup': 500,
      'Concrete & Crack Fix': 600,
      'Brick Work (Daily Rate)': 800,
    },
    'Home Cleaning': {
      'Full Home Deep Clean': 1500,
      'Kitchen Deep Cleaning': 600,
      'Bathroom Disinfection': 400,
      'Sofa & Carpet Wash': 500,
    },
    'AC Repair': {
      'AC Filter & Cleaning': 399,
      'Gas Leakage & Refill': 1200,
      'Installation / Uninstallation': 799,
      'Compressor Checkup': 450,
    },
    'Painter': {
      'Single Room Painting': 1200,
      'Waterproofing Coat': 800,
      'Exterior Touchup': 1500,
    },
  };

  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    return adminEmails.contains(email.toLowerCase().trim());
  }
}
