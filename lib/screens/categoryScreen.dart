import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> categories = const [
    {"name": "Electrician", "icon": Icons.electrical_services, "color": Colors.orangeAccent},
    {"name": "Plumber", "icon": Icons.plumbing, "color": Colors.blueAccent},
    {"name": "Carpenter", "icon": Icons.carpenter, "color": Colors.brown},
    {"name": "Barber / Salon", "icon": Icons.content_cut, "color": Colors.pinkAccent},
    {"name": "Mason (Mistri)", "icon": Icons.construction, "color": Colors.grey},
    {"name": "Home Cleaning", "icon": Icons.cleaning_services, "color": Colors.green},
    {"name": "Painter", "icon": Icons.format_paint, "color": Colors.purpleAccent},
    {"name": "AC Repair", "icon": Icons.handyman, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Local Services Assam", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aapko kis service ki zaroorat hai?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var item = categories[index];
                  return InkWell(
                    onTap: () {
                      // Category Name ke sath Map screen par bhejta hai
                      Navigator.pushNamed(
                        context, 
                        '/mappage', 
                        arguments: item["name"]
                      );
                    },
                    child: Card(
                      color: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: (item["color"] as Color).withOpacity(0.2),
                            child: Icon(item["icon"], color: item["color"], size: 30),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item["name"],
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
