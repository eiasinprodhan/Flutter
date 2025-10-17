import 'package:flutter/material.dart';
import 'package:crems/pages/UserProfile.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: _buildCardDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Info Cards in 1 Row (up to 4 columns)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInfoCard("Total Properties", "120", Icons.home, screenWidth),
                _buildInfoCard("Available", "45", Icons.check_circle_outline, screenWidth),
                _buildInfoCard("Rented", "75", Icons.verified_user, screenWidth),
                _buildInfoCard("Tenants", "60", Icons.people, screenWidth),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildActivityItem("Added new property: Sunset Villa"),
            _buildActivityItem("Updated tenant: John Doe"),
            _buildActivityItem("Received rent payment: \$1200"),
          ],
        ),
      ),
    );
  }

  /// 🔹 Info Card Responsive
  Widget _buildInfoCard(String title, String value, IconData icon, double screenWidth) {
    double cardWidth;

    if (screenWidth >= 1200) {
      cardWidth = (screenWidth - 80) / 4; // 4 columns
    } else if (screenWidth >= 800) {
      cardWidth = (screenWidth - 64) / 3;
    } else if (screenWidth >= 600) {
      cardWidth = (screenWidth - 48) / 2;
    } else {
      cardWidth = screenWidth - 32;
    }

    return Container(
      width: cardWidth,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Activity Card
  Widget _buildActivityItem(String description) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.notifications_none, color: Colors.deepPurple),
        title: Text(description),
      ),
    );
  }

  /// 🔹 Beautiful Card-style Drawer
  Widget _buildCardDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[200],
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(Icons.person, size: 40, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "John Smith",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "john.smith@example.com",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),

                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    label: 'My Profile',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserProfile()),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {},
                  ),
                  const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () {
                      // TODO: Add logout logic
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.deepPurple,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor, fontSize: 16)),
      onTap: onTap,
    );
  }
}
