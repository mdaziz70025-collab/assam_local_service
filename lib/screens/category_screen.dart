import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "";

  final List<Map<String, dynamic>> allCategories = const [
    {"name": "Electrician", "icon": Icons.electrical_services, "color": Colors.orangeAccent},
    {"name": "Plumber", "icon": Icons.plumbing, "color": Colors.blueAccent},
    {"name": "Carpenter", "icon": Icons.carpenter, "color": Colors.brown},
    {"name": "Barber / Salon", "icon": Icons.content_cut, "color": Colors.pinkAccent},
    {"name": "Mason (Mistri)", "icon": Icons.construction, "color": Colors.grey},
    {"name": "Home Cleaning", "icon": Icons.cleaning_services, "color": Colors.green},
    {"name": "Painter", "icon": Icons.format_paint, "color": Colors.purpleAccent},
    {"name": "AC Repair", "icon": Icons.handyman, "color": Colors.teal},
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/bookingScreen');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Search query ke hisab se categories filter hongi
    final filteredCategories = allCategories
        .where((cat) => (cat["name"] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.blueGrey[900]!,
      appBar: AppBar(
        title: const Text(
          "Local Services Assam",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: Colors.blueGrey[900]!,
        elevation: 0,
        actions: [
          // 🔴 Profile Icon Button
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30, color: Colors.orangeAccent),
            tooltip: "Profile",
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔴 Live Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search service (e.g. Electrician, Plumber)...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.orangeAccent),
                filled: true,
                fillColor: Colors.blueGrey[800],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Aapko kis service ki zaroorat hai?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),

            // Categories Grid
            Expanded(
              child: filteredCategories.isEmpty
                  ? const Center(
                      child: Text(
                        "Koi service nahi mili",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        var item = filteredCategories[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/mappage',
                              arguments: item["name"],
                            );
                          },
                          child: Card(
                            color: Colors.blueGrey[800]!,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: (item["color"] as Color).withOpacity(0.2),
                                  child: Icon(
                                    item["icon"] as IconData,
                                    color: item["color"] as Color,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item["name"] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // 🔴 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blueGrey[800],
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
