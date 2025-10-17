import 'package:crems/pages/Dashboard.dart';
import 'package:crems/pages/Projects.dart';
import 'package:crems/pages/SignIn.dart';
import 'package:crems/services/AuthService.dart';
import 'package:crems/services/EmployeeService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final EmployeeService employeeService = EmployeeService();
  final AuthService authService = AuthService();

  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  final String _baseUrl = "http://127.0.0.1:8080/images/employees/";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final email = await authService.getUserEmail();
      if (email != null && mounted) {
        final data = await employeeService.getEmployeeByEmail(email);
        setState(() => _profile = data);
      }
    } catch (e) {
      debugPrint("Failed to load profile: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignIn()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? _buildErrorView()
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildInfoCard(
                    title: "Contact Information",
                    children: [
                      _buildInfoTile(
                        Icons.email_outlined,
                        "Email",
                        _profile?['email'] ?? 'N/A',
                      ),
                      _buildInfoTile(
                        Icons.phone_outlined,
                        "Phone",
                        _profile?['phone'] ?? 'N/A',
                      ),
                      _buildInfoTile(
                        Icons.location_on_outlined,
                        "Address",
                        _profile?['address'] ?? 'N/A',
                      ),
                    ],
                  ),
                  _buildInfoCard(
                    title: "Job Details",
                    children: [
                      _buildInfoTile(
                        Icons.calendar_today_outlined,
                        "Joining Date",
                        _formatDate(_profile?['joiningDate']),
                      ),
                      _buildInfoTile(
                        Icons.attach_money_outlined,
                        "Salary",
                        "${_profile?['salary']?.toString() ?? 'N/A'} (${_profile?['salaryType'] ?? ''})",
                      ),
                      _buildInfoTile(
                        Icons.public_outlined,
                        "Country",
                        _profile?['country'] ?? 'N/A',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Dashboard'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Projects'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Projects()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Profile'),
            onTap: () {
              /* TODO */
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              /* TODO */
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final photoUrl = _getPhotoUrl();
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        image: DecorationImage(
          image: NetworkImage(
            'https://www.transparenttextures.com/patterns/dot-grid.png',
          ),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildProfileAvatar(radius: 32, photoUrl: photoUrl),
          const SizedBox(height: 12),
          Text(
            _profile?['name'] ?? 'Employee Name',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _profile?['email'] ?? 'No Email',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final photoUrl = _getPhotoUrl();
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 120,
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Positioned(
          top: 40,
          child: Column(
            children: [
              _buildProfileAvatar(
                radius: 65,
                photoUrl: photoUrl,
                hasBorder: true,
              ),
              const SizedBox(height: 12),
              Text(
                _profile?['name'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(
                  _profile?['role']?.replaceAll('_', ' ') ??
                      'Role not specified',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const Divider(height: 24, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.deepPurple.withOpacity(0.7), size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar({
    required double radius,
    String? photoUrl,
    bool hasBorder = false,
  }) {
    return Container(
      decoration: hasBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            )
          : null,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: photoUrl == null
            ? Icon(Icons.person, size: radius, color: Colors.grey[400])
            : ClipOval(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, stackTrace) {
                    // This error builder is now more important! It will catch connection issues.
                    debugPrint("Error loading image: $error");
                    return Icon(
                      Icons.person,
                      size: radius,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Could Not Load Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getPhotoUrl() {
    final String? photoName = _profile?['photo'];
    return (photoName != null && photoName.isNotEmpty)
        ? "$_baseUrl$photoName"
        : null;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      return DateFormat.yMMMMd().format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }
}
