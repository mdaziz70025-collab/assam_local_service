import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🛍️ Add New Product Dialog
  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final oldPriceCtrl = TextEditingController();
    String selectedTag = 'Best Seller';
    String selectedCategory = 'Electrician';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add New Store Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Product Name", labelStyle: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Selling Price (₹)", labelStyle: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: oldPriceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Cutout / Old Price (₹)", labelStyle: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTag,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Marketing Tag", labelStyle: TextStyle(color: Colors.white70)),
                  items: ['Best Seller', 'Hot Deal', 'Popular', '25% OFF', 'New Arrival']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedTag = val!),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Category", labelStyle: TextStyle(color: Colors.white70)),
                  items: ['Electrician', 'Plumber', 'Carpenter', 'Painter', 'AC Repair', 'Cleaning']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedCategory = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                await FirebaseFirestore.instance.collection('products').add({
                  'name': nameCtrl.text.trim(),
                  'price': int.tryParse(priceCtrl.text.trim()) ?? 0,
                  'oldPrice': int.tryParse(oldPriceCtrl.text.trim()) ?? 0,
                  'tag': selectedTag,
                  'category': selectedCategory,
                  'isAvailable': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Product added to Store successfully!"), backgroundColor: Colors.green),
                );
              },
              child: const Text("SAVE PRODUCT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("👑 Admin Command Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: "Overview"),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: "Live Orders"),
            Tab(icon: Icon(Icons.verified_user_rounded), text: "Partners"),
            Tab(icon: Icon(Icons.storefront_rounded), text: "Products"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orangeAccent,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Product", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: _showAddProductDialog,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildLiveOrdersTab(),
          _buildPartnersTab(),
          _buildProductsTab(),
        ],
      ),
    );
  }

  // 📊 TAB 1: Real-time Analytics & Revenue
  Widget _buildOverviewTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, orderSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('providers').snapshots(),
          builder: (context, partnerSnap) {
            final orders = orderSnap.data?.docs ?? [];
            final partners = partnerSnap.data?.docs ?? [];

            int totalRevenue = 0;
            int completedJobs = 0;
            int pendingJobs = 0;

            for (var doc in orders) {
              final d = doc.data() as Map<String, dynamic>;
              final amt = d['totalAmount'] ?? 0;
              final status = d['status'] ?? '';

              if (status.toString().contains("Completed")) {
                totalRevenue += (amt as num).toInt();
                completedJobs++;
              } else if (!status.toString().contains("Rejected")) {
                pendingJobs++;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Business Performance", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard("Gross Revenue", "₹ $totalRevenue", Icons.currency_rupee, Colors.greenAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard("Platform Comm. (10%)", "₹ ${(totalRevenue * 0.10).toInt()}", Icons.account_balance_wallet, Colors.orangeAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard("Total Partners", "${partners.length}", Icons.people_alt, Colors.cyanAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard("Pending Orders", "$pendingJobs", Icons.pending_actions, Colors.amberAccent)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Quick Status Breakdown", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        _buildStatusRow("Completed Orders", completedJobs, Colors.greenAccent),
                        const Divider(color: Colors.white10),
                        _buildStatusRow("Active / On The Way", pendingJobs, Colors.orangeAccent),
                        const Divider(color: Colors.white10),
                        _buildStatusRow("Registered Partners in Assam", partners.length, Colors.blueAccent),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 📦 TAB 2: Live Orders Monitoring
  Widget _buildLiveOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No bookings recorded yet.", style: TextStyle(color: Colors.white60)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final d = docs[idx].data() as Map<String, dynamic>;
            final id = docs[idx].id;
            final custName = d['customerName'] ?? 'Customer';
            final custPhone = d['customerPhone'] ?? 'N/A';
            final category = d['category'] ?? 'Service';
            final amount = d['totalAmount'] ?? 0;
            final address = d['customerAddress'] ?? 'Assam';
            final status = d['status'] ?? 'Pending';
            final partnerName = d['assignedPartnerName'] ?? 'Not Assigned';
            final otp = d['completionOtp'] ?? 'N/A';

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$category (₹$amount)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(status, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("👤 Customer: $custName ($custPhone)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("📍 Address: $address", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("🛠️ Partner: $partnerName", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                  Text("🔐 Secret OTP: $otp", style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text("Delete Record", style: TextStyle(fontSize: 11)),
                        onPressed: () => FirebaseFirestore.instance.collection('bookings').doc(id).delete(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🛠️ TAB 3: Partner KYC & Verification Control
  Widget _buildPartnersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('providers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No registered partners yet.", style: TextStyle(color: Colors.white60)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final p = docs[idx].data() as Map<String, dynamic>;
            final id = docs[idx].id;
            final name = p['name'] ?? 'Partner';
            final phone = p['phone'] ?? 'N/A';
            final cat = p['category'] ?? 'General';
            final loc = p['location'] ?? 'Assam';
            final bool isVerified = p['isVerified'] ?? true;
            final int jobs = p['totalJobs'] ?? 0;
            final int earnings = p['totalEarnings'] ?? 0;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isVerified ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isVerified ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(isVerified ? "Approved" : "Blocked", style: TextStyle(color: isVerified ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("$cat • $loc • 📞 $phone", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("Total Jobs: $jobs Done • Wallet Earned: ₹$earnings", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isVerified ? Colors.redAccent : Colors.greenAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('providers').doc(id).update({'isVerified': !isVerified});
                          },
                          child: Text(isVerified ? "BLOCK / SUSPEND" : "APPROVE & VERIFY", style: TextStyle(color: isVerified ? Colors.redAccent : Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🛍️ TAB 4: Store Products & Marketing Items Manager
  Widget _buildProductsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No custom products yet. Tap + to add!", style: TextStyle(color: Colors.white60)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final pr = docs[idx].data() as Map<String, dynamic>;
            final id = docs[idx].id;
            final name = pr['name'] ?? 'Product';
            final price = pr['price'] ?? 0;
            final oldPrice = pr['oldPrice'] ?? 0;
            final tag = pr['tag'] ?? 'Deal';
            final cat = pr['category'] ?? 'General';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                              child: Text(tag, style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Text(cat, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text("₹$price (Old: ₹$oldPrice)", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => FirebaseFirestore.instance.collection('products').doc(id).delete(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text("$count", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
