import 'package:flutter/material.dart';

class ServiceBody extends StatefulWidget {
  final String serviceCategory; // Category pass hogi
  const ServiceBody({Key? key, this.serviceCategory = "Electrician"}) : super(key: key);

  @override
  _ServiceBodyState createState() => _ServiceBodyState();
}

class _ServiceBodyState extends State<ServiceBody> {
  int _amount = 0;
  int _quantity = 0;
  bool _booking = false;

  // Multi-Category Service Rate List
  final Map<String, Map<String, int>> masterServices = const {
    "Electrician": {
      'Switchboard Repair': 150,
      'Ceiling Fan Fitting': 200,
      'Wiring Checkup': 350,
      'Inverter Setup': 500,
    },
    "Plumber": {
      'Pipe Leakage Repair': 200,
      'Tap / Faucet Fitting': 150,
      'Water Tank Cleaning': 600,
      'Basin Installation': 400,
    },
    "Carpenter": {
      'Door Lock Repair': 200,
      'Bed / Furniture Repair': 450,
      'Modular Kitchen Fitting': 800,
      'Window Latch Fix': 150,
    },
    "Barber / Salon": {
      'Haircut': 100,
      'Beard Trimming': 80,
      'Face Massage / Facial': 300,
      'Hair Color': 250,
    },
    "Mason (Mistri)": {
      'Tile Fitting Work (per sq ft)': 40,
      'Wall Plaster Touchup': 500,
      'Concrete Fix': 600,
      'Brick Work (Daily Rate)': 800,
    },
    "Home Cleaning": {
      'Full Home Deep Clean': 1500,
      'Kitchen Cleaning': 600,
      'Bathroom Cleaning': 400,
    }
  };

  late Map<String, int> selectedCategoryServices;
  late List<bool> _check;

  @override
  void initState() {
    super.initState();
    // Default fallback agar category na mile
    selectedCategoryServices = masterServices[widget.serviceCategory] ?? masterServices["Electrician"]!;
    _check = List<bool>.filled(selectedCategoryServices.length, false);
  }

  Widget servicePriceWidget(String name, int price, int index) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    _check[index] = !_check[index];
                    if (_check[index]) {
                      ++_quantity;
                      _amount += price;
                    } else {
                      --_quantity;
                      _amount -= price;
                    }
                    _booking = _check.contains(true);
                  });
                },
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: _check[index] ? Colors.blueAccent : Colors.white38,
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Icon(
                    !_check[index] ? Icons.add : Icons.check,
                    size: 20.0,
                    color: !_check[index] ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              Text(
                '₹ $price',
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        for (int i = 0; i < selectedCategoryServices.length; i++)
          servicePriceWidget(
            selectedCategoryServices.keys.elementAt(i),
            selectedCategoryServices.values.elementAt(i),
            i,
          ),
        const SizedBox(height: 30),
        Container(
          height: 65,
          color: Colors.white10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_quantity Item Selected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _booking ? Colors.white : Colors.white54,
                    ),
                  ),
                  if (_booking)
                    Text(
                      'Total: ₹ $_amount',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (_booking) {
                    Navigator.pushNamed(
                      context, 
                      '/appointmentScreen',
                      arguments: {
                        'category': widget.serviceCategory,
                        'totalAmount': _amount,
                        'itemCount': _quantity,
                      }
                    );
                  }
                },
                child: Card(
                  color: _booking ? Colors.blueAccent : Colors.grey[850]!,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _booking ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
