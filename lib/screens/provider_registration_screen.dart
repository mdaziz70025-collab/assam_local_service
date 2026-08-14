import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({Key? key}) : super(key: key);

  @override
  _ProviderRegistrationScreenState createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCategory = 'Electrician';
  final List<String> _categories = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Barber / Salon',
    'Mason (Mistri)',
    'Home Cleaning',
    'Painter',
    'AC Repair',
  ];

  Future<void> _submitPartnerToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('providers').add({
        'userId': user?.uid ?? '',
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'experience': _experienceController.text.trim(),
        'baseRate': int.tryParse(_rateController.text.trim()) ?? 299,
        'location': _locationController.text.trim(),
        'isVerified': true,
        'rating': 5.0,
        'completedOrders': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "🎉 Partner Profile Saved! You are now live in Assam.",
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration Failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Partner Registration",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orangeAccent.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.handyman,
                          color: Colors.orangeAccent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Join as a Service Partner",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Get local booking orders directly across Assam.",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Partner Details",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _nameController,
                  label: "Full Name / Enterprise Name",
                  hint: "e.g. Pranab Kalita",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _phoneController,
                  label: "Mobile Number",
                  hint: "e.g. 70025XXXXX",
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                const Text(
                  "Service Category",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF1E293B),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.orangeAccent),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _experienceController,
                  label: "Experience",
                  hint: "e.g. 5 Years Experience",
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _rateController,
                  label: "Starting Service Charge (₹)",
                  hint: "e.g. 299",
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _locationController,
                  label: "Service Area in Assam",
                  hint: "e.g. Beltola, Guwahati",
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isSaving ? null : _submitPartnerToFirestore,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "REGISTER AS PARTNER",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.orangeAccent, size: 20),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.2),
        ),
      ),
    );
  }
}
