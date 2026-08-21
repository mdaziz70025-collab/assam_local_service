import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mappage extends StatefulWidget {
  const Mappage({Key? key}) : super(key: key);

  @override
  _MappageState createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  final MapType _mapType = MapType.normal;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(26.1445, 91.7362),
    zoom: 13.0,
  );

  final List<Map<String, dynamic>> _localExperts = [
    {
      "name": "Pranab Kalita",
      "rating": 4.9,
      "jobs": 142,
      "loc": const LatLng(26.1500, 91.7400),
      "area": "GS Road, Guwahati"
    },
    {
      "name": "Bipul Sharma",
      "rating": 4.7,
      "jobs": 89,
      "loc": const LatLng(26.1380, 91.7320),
      "area": "Beltola, Guwahati"
    },
    {
      "name": "Rahim Ali",
      "rating": 4.8,
      "jobs": 210,
      "loc": const LatLng(26.1550, 91.7500),
      "area": "Dispur, Assam"
    },
    {
      "name": "Dipankar Das",
      "rating": 4.8,
      "jobs": 95,
      "loc": const LatLng(26.1300, 91.7250),
      "area": "Six Mile, Guwahati"
    },
  ];

  void _onMapCreated(GoogleMapController controller) {
    for (int i = 0; i < _localExperts.length; i++) {
      final expert = _localExperts[i];
      final MarkerId markerId = MarkerId(i.toString());
      final Marker marker = Marker(
        markerId: markerId,
        position: expert["loc"] as LatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: expert["name"],
          snippet: "⭐ ${expert['rating']} (${expert['jobs']} completed)",
        ),
      );
      _markers[markerId] = marker;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String selectedCategory =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? "Electrician";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            mapType: _mapType,
            markers: Set<Marker>.of(_markers.values),
            initialCameraPosition: _kInitialPosition,
            onMapCreated: _onMapCreated,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1E293B),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Text(
                        "Live $selectedCategory Experts in Assam",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$selectedCategory Partners Found",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "● Live Nearby",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${_localExperts.length} verified experts ready near Guwahati & Assam.",
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long, color: Colors.black),
                      label: Text(
                        "VIEW $selectedCategory RATE LIST",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/appointmentScreen',
                          arguments: selectedCategory,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
