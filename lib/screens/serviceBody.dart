import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceBody extends StatefulWidget {
  final String serviceCategory;
  const ServiceBody({Key? key, this.serviceCategory = "Electrician"}) : super(key: key);

  @override
  _ServiceBodyState createState() => _ServiceBodyState();
}

class _ServiceBodyState extends State<ServiceBody> {
  int _totalAmount = 0;
  int _totalQuantity = 0;
  bool _isBooking = false;

  String _selectedDate = "Today";
  String _selectedSlot = "10:00 AM - 12:00 PM";
  final String _selectedPayment = "Cash on Delivery (Pay After Service)";

  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();

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
      'AC Filter & Cleaning': 399,
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

  Future<void> _placeOrderInFirestore(BuildContext sheetContext) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first to book.")),
      );
      return;
    }

    if (_customerPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter mobile number for partner to call."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      List<Map<String, dynamic>> bookedItems = [];
      _itemQuantities.forEach((key, value) {
        if (value > 0) {
          bookedItems.add({
            "serviceName": key,
            "quantity": value,
            "unitPrice": selectedCategoryServices[key],
          });
        }
      });

      // 🔐 Generate 4-digit secret OTP
      final String completionOtp = (1000 + Random().nextInt(9000)).toString();

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'customerName': user.displayName ?? "Customer",
        'customerPhone': _customerPhoneController.text.trim(),
        'customerAddress': _customerAddressController.text.trim().isNotEmpty
            ? _customerAddressController.text.trim()
            : "Assam Local Address",
        'category': widget.serviceCategory,
        'items': bookedItems,
        'totalAmount': _totalAmount,
        'totalQuantity': _totalQuantity,
        'scheduledDate': _selectedDate,
        'scheduledSlot': _selectedSlot,
        'paymentMode': _selectedPayment,
        'completionOtp': completionOtp,
        'status': 'Partner Assigned',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(sheetContext);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎉 Order Placed! Share OTP $completionOtp with partner after work.",
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking Failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _openCheckoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final List<String> days = ["Today", "Tomorrow", "Day After"];
            final List<String> slots = [
              "09:00 AM - 11:00 AM",
              "11:00 AM - 01:00 PM",
              "02:00 PM - 04:00 PM",
              "04:00 PM - 06:00 PM",
              "06:00 PM - 08:00 PM"
            ];

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Booking Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _customerPhoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Your Phone Number (For Partner Call)",
                        hintText: "e.g. 70025XXXXX",
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                        labelStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                        prefixIcon: const Icon(Icons.phone, color: Colors.orangeAccent, size: 20),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _customerAddressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "House No / Gaon / Landmark",
                        hintText: "e.g. Near Daily Bazar, Kodalduwa",
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                        prefixIcon: const Icon(Icons.home, color: Colors.orangeAccent, size: 20),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Select Date & Time Slot",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: days.map((day) {
                        final isSelected = _selectedDate == day;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => _selectedDate = day),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orangeAccent : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots.map((s) {
                        final isSelected = _selectedSlot == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: isSelected,
                          selectedColor: Colors.orangeAccent,
                          backgroundColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            setSheetState(() => _selectedSlot = s);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isBooking ? null : () => _placeOrderInFirestore(ctx),
                        child: _isBooking
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                "CONFIRM BOOKING (₹$_totalAmount)",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _totalQuantity > 0;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: selectedCategoryServices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                );
              },
            ),
          ),
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
                    onPressed: hasSelection ? _openCheckoutBottomSheet : null,
                    child: Text(
                      "Select Slot",
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
    );
  }
}
