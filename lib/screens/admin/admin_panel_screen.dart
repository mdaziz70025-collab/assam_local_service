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
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final oldPriceController = TextEditingController();
    String category = 'Electrician';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add New Store Product", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Product Name", labelStyle: TextStyle(color: Colors.white60))),
            TextField(controller: priceController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Selling Price (₹)", labelStyle: TextStyle(color: Colors.white60))),
            TextField(controller: oldPriceController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Cutout / Old Price (₹)", labelStyle: TextStyle(color: Colors.white60))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('products').add({
                  'name': nameController.text.trim(),
                  'price': int.tryParse(priceController.text.trim()) ?? 0,
                  'oldPrice': int.tryParse(oldPriceController.text.trim()) ?? 0,
                  'category': category,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("SAVE PRODUCT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 22),
            SizedBox(width: 8),
            Text("Admin Command Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: "Overview"),
            Tab(icon: Icon(Icons.receipt_long), text: "Live Orders"),
            Tab(icon: Icon(Icons.verified), text: "Partners"),
            Tab(icon: Icon(Icons.storefront), text: "Products"),
          ],
        ),
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
      // 🎯 FAB only appears on Products Tab (Index 3)
      floatingActionButton: _tabController.index == 3
          ? FloatingActionButton.extended(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text("Add Product", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _showAddProductDialog,
            )
          : null,
    );
  }

  Widget _buildOverviewTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        int completedOrders = 0;
        int activeOrders = 0;
        int grossRevenue = 0;

        for (var d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final status = data['status'] ?? '';
          final amount = data['totalAmount'] ?? 0;
          if (status == "Service Completed") {
            completedOrders++;
            grossRevenue += (amount as num).toInt();
          } else if (status.contains("Accepted")) {
            activeOrders++;
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: _buildMetricCard("Gross Revenue", "₹ $grossRevenue", Icons.currency_rupee, Colors.greenAccent)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard("Commission (10%)", "₹ ${(grossRevenue * 0.1).toInt()}", Icons.account_balance_wallet, Colors.amberAccent)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard("Active Orders", "$activeOrders", Icons.pending_actions, Colors.orangeAccent)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard("Completed", "$completedOrders", Icons.task_alt, Colors.cyanAccent)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLiveOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        final orders = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final data = orders[i].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            final otp = data['completionOtp'];
            final showOtp = status.contains("Accepted");

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${data['category']} (₹${data['totalAmount']})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(status, style: TextStyle(color: status == "Service Completed" ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Customer: ${data['customerName']} • ${data['customerAddress']}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  if (showOtp && otp != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text("🔐 Completion OTP: $otp", style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPartnersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('providers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        final providers = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: providers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final p = providers[i].data() as Map<String, dynamic>;
            final isVerified = p['isVerified'] ?? false;
            final id = providers[i].id;

            return ListTile(
              tileColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(p['name'] ?? 'Partner', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("${p['category']} • ${p['location'] ?? 'Assam'}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
              trailing: Switch(
                value: isVerified,
                activeColor: Colors.greenAccent,
                onChanged: (val) => FirebaseFirestore.instance.collection('providers').doc(id).update({'isVerified': val}),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No custom products yet. Tap + to add!", style: TextStyle(color: Colors.white38)));
        }
        final prods = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: prods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final d = prods[i].data() as Map<String, dynamic>;
            return ListTile(
              tileColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(d['name'] ?? '', style: const TextStyle(color: Colors.white)),
              subtitle: Text("₹${d['price']} (Cutout: ₹${d['oldPrice']})", style: const TextStyle(color: Colors.orangeAccent)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => FirebaseFirestore.instance.collection('products').doc(prods[i].id).delete(),
              ),
            );
          },
        );
      },
    );
  }
}
