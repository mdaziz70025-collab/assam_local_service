import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 0: Pending, 1: Accepted, 2: In Progress, 3: Completed
  int currentTrackerStep = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Current Bookings'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 🔴 Tab 1: Live Tracking for Active Booking
          _buildCurrentBookingTab(),

          // 🔴 Tab 2: Past Booking History
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // Active/Live Booking Status UI
  Widget _buildCurrentBookingTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.build_circle,
                    color: Colors.orangeAccent, size: 45),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Electrician Repair Service",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Booking ID: #ALS-9842",
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          const Text(
            "Live Booking Tracker",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Stepper Tracker
          Expanded(
            child: ListView(
              children: [
                _buildStatusItem(
                  step: 0,
                  title: "Booking Requested",
                  subtitle: "Searching for nearby providers in Assam",
                  icon: Icons.send,
                ),
                _buildStatusItem(
                  step: 1,
                  title: "Provider Accepted",
                  subtitle: "Rahul Sharma (Electrician) is assigned",
                  icon: Icons.person_pin_circle,
                ),
                _buildStatusItem(
                  step: 2,
                  title: "Service In Progress",
                  subtitle: "Provider is working at your location",
                  icon: Icons.handyman,
                ),
                _buildStatusItem(
                  step: 3,
                  title: "Completed",
                  subtitle: "Share OTP with provider after work is done",
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ),

          // OTP Box for security
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.15),
              border: Border.all(color: Colors.orangeAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Service Completion OTP:",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("4 8 2 9",
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Completed Booking History List
  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHistoryCard(
          serviceName: "Plumbing Repair",
          date: "28 Jan 2026",
          amount: "₹350",
          status: "Completed",
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          serviceName: "AC Maintenance",
          date: "15 Dec 2025",
          amount: "₹600",
          status: "Completed",
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required int step,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isDone = currentTrackerStep >= step;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDone ? Colors.orangeAccent : Colors.grey[800],
              child: Icon(icon,
                  size: 18, color: isDone ? Colors.black : Colors.white38),
            ),
            if (step < 3)
              Container(
                width: 2,
                height: 40,
                color: isDone ? Colors.orangeAccent : Colors.grey[800],
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDone ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String serviceName,
    required String date,
    required String amount,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.white54)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
