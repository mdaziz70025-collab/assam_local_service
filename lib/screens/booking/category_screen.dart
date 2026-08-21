import 'package:flutter/material.dart';
import 'service_body.dart';

class CategoryScreen extends StatefulWidget {
  final String? categoryName;

  const CategoryScreen({Key? key, this.categoryName}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _searchQuery = "";

  final List<Map<String, dynamic>> allCategories = const [
    {"name": "Electrician", "icon": Icons.electrical_services, "color": Colors.orangeAccent},
    {"name": "Plumber", "icon": Icons.plumbing, "color": Colors.cyan},
    {"name": "Carpenter", "icon": Icons.carpenter, "color": Colors.brown},
    {"name": "Barber / Salon", "icon": Icons.content_cut, "color": Colors.pinkAccent},
    {"name": "Mason (Mistri)", "icon": Icons.construction, "color": Colors.grey},
    {"name": "Home Cleaning", "icon": Icons.cleaning_services, "color": Colors.green},
    {"name": "Painter", "icon": Icons.format_paint, "color": Colors.purpleAccent},
    {"name": "AC Repair", "icon": Icons.handyman, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    // Agar direct kisi specific category ke liye open kiya gaya ho, toh seedha ServiceBody render karein
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text(
            "${widget.categoryName} Services",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
          ),
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: ServiceBody(categoryName: widget.categoryName!),
      );
    }

    final filteredCategories = allCategories
        .where((cat) => (cat["name"] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Local Services Assam",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search service (e.g. Electrician, Plumber)...",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.orangeAccent),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "What service do you need today?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: filteredCategories.isEmpty
                  ? const Center(
                      child: Text(
                        "No services found",
                        style: TextStyle(color: Colors.white54, fontSize: 14),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  backgroundColor: const Color(0xFF0F172A),
                                  appBar: AppBar(
                                    title: Text(
                                      "${item['name']} Services",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                  ),
                                  body: ServiceBody(categoryName: item["name"]),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.white.withOpacity(0.06)),
                            ),
                            elevation: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: (item["color"] as Color).withOpacity(0.18),
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
                                    fontSize: 14,
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
    );
  }
}
