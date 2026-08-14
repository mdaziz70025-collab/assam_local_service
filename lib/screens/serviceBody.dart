import 'package:flutter/material.dart';

class ServiceBody extends StatefulWidget {
  final String serviceCategory;
  const ServiceBody({Key? key, this.serviceCategory = "Electrician"}) : super(key: key);

  @override
  _ServiceBodyState createState() => _ServiceBodyState();
}

class _ServiceBodyState extends State<ServiceBody> {
  int _totalAmount = 0;
  int _totalQuantity = 0;

  final Map<String, Map<String, int>> masterServices = const {
    "Electrician": {
      'Switchboard Repair / Replace': 150,
      'Ceiling Fan Installation': 200,
      'Full Wiring Checkup': 350,
      'Inverter & Battery Setup': 500,
      'MCB / Fuse Box Repair': 250,
    },
    "Plumber": {
      'Pipe Leakage Repair': 200,
      'Tap / Faucet Fitting': 150,
      'Water Tank Cleaning': 600,
      'Basin & Sink Installation': 400,
      'Drainage Blockage Clearing': 350,
    },
    "Carpenter": {
      'Door Lock Repair / Installation': 200,
      'Bed / Furniture Repair': 450,
      'Modular Kitchen Fitting': 800,
      'Window Latch & Hinges Fix': 150,
    },
    "Barber / Salon": {
      'Men Haircut': 100,
      'Beard Grooming & Shape': 80,
      'Face Cleansing & Facial': 300,
      'Hair Color & Treatment': 250,
    },
    "Mason (Mistri)": {
      'Tile Fitting Work (per sq ft)': 40,
      'Wall Plaster Touchup': 500,
      'Concrete & Crack Fix': 600,
      'Brick Work (Daily Rate)': 800,
    },
    "Home Cleaning": {
      'Full Home Deep Clean': 1500,
      'Kitchen Deep Cleaning': 600,
      'Bathroom Disinfection': 400,
      'Sofa & Carpet Wash': 500,
    },
    "AC Repair": {
      'AC Filter & Coil Cleaning': 399,
      'Gas Leakage & Refill': 1200,
      'Installation / Uninstallation': 799,
      'Compressor Checkup': 450,
    },
    "Painter": {
      'Single Room Painting': 1200,
      'Waterproofing Coat': 800,
      'Exterior Touchup': 1500,
    }
  };

  late Map<String, int> selectedCategoryServices;
  late Map<String, int> _itemQuantities;

  @override
  void initState() {
    super.initState();
    selectedCategoryServices =
        masterServices[widget.serviceCategory] ?? masterServices["Electrician"]!;
    _itemQuantities = {for (var key in selectedCategoryServices.keys) key: 0};
  }

  void _incrementItem(String name, int price) {
    setState(() {
      _itemQuantities[name] = (_itemQuantities[name] ?? 0) + 1;
      _totalQuantity++;
      _totalAmount += price;
    });
  }

  void _decrementItem(String name, int price) {
    if ((_itemQuantities[name] ?? 0) > 0) {
      setState(() {
        _itemQuantities[name] = (_itemQuantities[name] ?? 0) - 1;
        _totalQuantity--;
        _totalAmount -= price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _totalQuantity > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: selectedCategoryServices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final serviceName = selectedCategoryServices.keys.elementAt(index);
                final price = selectedCategoryServices.values.elementAt(index);
                final qty = _itemQuantities[serviceName] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: qty > 0
                          ? Colors.orangeAccent.withOpacity(0.5)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.handyman_outlined,
                          color: Colors.orangeAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹ $price",
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (qty == 0)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.orangeAccent,
                            side: const BorderSide(color: Colors.orangeAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onPressed: () => _incrementItem(serviceName, price),
                          child: const Text(
                            "ADD",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    size: 16, color: Colors.black),
                                onPressed: () => _decrementItem(serviceName, price),
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                              Text(
                                "$qty",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    size: 16, color: Colors.black),
                                onPressed: () => _incrementItem(serviceName, price),
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Checkout Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$_totalQuantity Item${_totalQuantity == 1 ? '' : 's'} Selected",
                        style: TextStyle(
                          color: hasSelection ? Colors.white70 : Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹ $_totalAmount",
                        style: TextStyle(
                          color: hasSelection ? Colors.orangeAccent : Colors.white38,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasSelection
                            ? Colors.orangeAccent
                            : Colors.white12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      onPressed: hasSelection
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "🎉 Booking Confirmed for ${widget.serviceCategory}! Total: ₹$_totalAmount"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.popUntil(context, (route) => route.isFirst);
                            }
                          : null,
                      child: Text(
                        "Confirm Order",
                        style: TextStyle(
                          color: hasSelection ? Colors.black : Colors.white38,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
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
