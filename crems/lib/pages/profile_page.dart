// lib/pages/profile_page.dart


import 'package:CREMS/models/customer.dart';
import 'package:CREMS/models/transaction.dart';
import 'package:CREMS/pages/bookings_page.dart';
import 'package:CREMS/pages/customers_page.dart';
import 'package:CREMS/pages/raw_materials_page.dart';
import 'package:CREMS/pages/transactions_page.dart';
import 'package:CREMS/services/customer_service.dart';
import 'package:CREMS/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/building.dart';
import '../models/employee.dart'; // Ensure this points to your new Employee model
import '../models/floor.dart';
import '../models/project.dart';
import '../models/stage.dart';
import '../models/unit.dart';
import '../services/auth_service.dart';
import '../services/building_service.dart';
import '../services/employee_service.dart';
import '../services/floor_service.dart';
import '../services/project_service.dart';
import '../services/stage_service.dart';
import '../services/unit_service.dart';
import 'buildings_page.dart';
import 'employees_page.dart';
import 'floors_page.dart';
import 'home_page.dart';
import 'projects_page.dart';
import 'stages_page.dart';
import 'units_page.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color primaryVioletDark = Color(0xFF4527A0);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentOrange = Color(0xFFFFB74D);
const Color accentGreen = Color(0xFF4CAF50);
const Color accentBlue = Color(0xFF42A5F5);
// --- END OF PALETTE ---

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Future<void> _dataLoadingFuture;

  Employee? _currentEmployee;
  String? _userRole;
  bool _isUserInfoLoading = true;

  List<Project> _projects = [];
  List<Building> _buildings = [];
  List<Employee> _employees = [];
  List<Floor> _floors = [];
  List<Unit> _units = [];
  List<Stage> _stages = [];
  List<Transaction> _transactions = [];
  List<Transaction> _recentTransactions = [];
  List<Customer> _customers = [];

  double _totalCredit = 0.0;
  double _totalDebit = 0.0;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _dataLoadingFuture = _loadAllData();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    if (!mounted) return;
    setState(() {
      _isUserInfoLoading = true;
    });
    try {
      final email = await AuthService.getUserEmail();
      final role = await AuthService.getUserRole();
      if (email != null) {
        final employee = await EmployeeService.getEmployeeByEmail(email);
        if (mounted) {
          setState(() {
            _currentEmployee = employee;
            _userRole = role ?? employee?.role; // Fallback to employee role if token role is null
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load current user data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isUserInfoLoading = false;
        });
      }
    }
  }

  Future<void> _loadAllData() async {
    try {
      final results = await Future.wait([
        ProjectService.getAllProjects(),
        BuildingService.getAllBuildings(),
        EmployeeService.getAllEmployees(),
        FloorService.getAllFloors(),
        UnitService.getAllUnits(),
        StageService.getAllStages(),
        TransactionService.getAllTransactions(),
        CustomerService.getAllCustomers(),
      ]);
      if (!mounted) return;
      setState(() {
        _projects = results[0] as List<Project>;
        _buildings = results[1] as List<Building>;
        _employees = results[2] as List<Employee>;
        _floors = results[3] as List<Floor>;
        _units = results[4] as List<Unit>;
        _stages = results[5] as List<Stage>;
        _transactions = results[6] as List<Transaction>;
        _customers = results[7] as List<Customer>;
        _calculateTransactionTotals();
        _prepareRecentTransactions();
        _isDataLoaded = true;
      });
    } catch (e) {
      debugPrint("Failed to load data: $e");
      if (mounted) {
        setState(() {
          _isDataLoaded = false;
        });
      }
      rethrow;
    }
  }

  void _calculateTransactionTotals() {
    double credit = 0.0;
    double debit = 0.0;
    for (var transaction in _transactions) {
      if (transaction.isCredit) {
        credit += transaction.amount ?? 0.0;
      } else {
        debit += transaction.amount ?? 0.0;
      }
    }
    _totalCredit = credit;
    _totalDebit = debit;
  }

  void _prepareRecentTransactions() {
    final sortedTransactions = List<Transaction>.from(_transactions);
    sortedTransactions.sort((a, b) {
      final dateA = a.date ?? DateTime(1900);
      final dateB = b.date ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });
    _recentTransactions = sortedTransactions.take(10).toList();
  }

  Future<void> _reloadData() async {
    setState(() {
      _dataLoadingFuture = _loadAllData();
      _loadCurrentUserData();
    });
  }

  Map<String, int> get _dataCounts => {
    'projects': _projects.length,
    'buildings': _buildings.length,
    'employees': _employees.length,
    'floors': _floors.length,
    'units': _units.length,
    'stages': _stages.length,
    'transactions': _transactions.length,
    'customers': _customers.length,
  };

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
        context: context, builder: (context) => _buildLogoutDialog());
    if (confirmed == true && mounted) {
      await AuthService.logoutAndClearSession();
      ScaffoldMessenger.of(context).showSnackBar(
        _buildStatusSnackBar(
            'Logged out successfully!', Icons.check_circle_rounded, accentGreen),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _dataLoadingFuture,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: backgroundLight,
          appBar: AppBar(
            backgroundColor: backgroundLight,
            foregroundColor: primaryViolet,
            title: const Text('Dashboard',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: primaryViolet)),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout_rounded, color: Colors.grey[700]),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: _buildDrawer(),
          body: RefreshIndicator(
            onRefresh: _reloadData,
            color: primaryViolet,
            child: _buildBody(snapshot),
          ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingProgress();
    }
    if (snapshot.hasError) {
      return _buildErrorWidget();
    }
    if (!_isDataLoaded) {
      return _buildErrorWidget();
    }

    _animationController.forward();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  // --- MODIFICATION START: Updated to use the new Employee model ---
  String _toTitleCase(String text) {
    if (text.isEmpty) return '';
    return text
        .split(RegExp(r'[\s_]+')) // Split by space or underscore
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting =
    hour >= 17 ? 'Good Evening' : (hour >= 12 ? 'Good Afternoon' : 'Good Morning');
    IconData greetingIcon =
    hour >= 17 ? Icons.nightlight_round : Icons.wb_sunny_rounded;

    // Use the new `name` field from the Employee model
    final String displayName = _isUserInfoLoading
        ? 'Loading...'
        : _currentEmployee?.name ?? 'User';

    final String displayRole = _isUserInfoLoading
        ? 'Fetching role...'
        : _toTitleCase(_userRole ?? 'User Role');

    // Use the new `photo` field for the image URL
    final Widget profileAvatar = _isUserInfoLoading
        ? const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white24,
        child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
        : _currentEmployee?.photo != null &&
        _currentEmployee!.photo!.isNotEmpty
        ? CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      backgroundImage: NetworkImage('http://localhost:8080/images/employees/' + _currentEmployee!.photo!),
    )
        : CircleAvatar(
      radius: 30,
      backgroundColor: secondaryViolet,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryViolet, secondaryViolet]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryViolet.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(greetingIcon, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(greeting,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 8),
                Text(displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2)),
                const SizedBox(height: 4),
                Text(displayRole,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(DateFormat('MMM dd, yyyy').format(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          profileAvatar,
        ],
      ),
    );
  }
  // --- MODIFICATION END ---

  // ... The rest of the file is unchanged ...

  Widget _buildLoadingProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryViolet),
                    strokeWidth: 3),
                const SizedBox(height: 20),
                const Text('Loading Dashboard',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryViolet)),
                const SizedBox(height: 8),
                Text('Please wait while we fetch your data...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final counts = _dataCounts;
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryViolet, primaryVioletDark],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            const Divider(
                color: Colors.white24,
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16),
            _buildDrawerItem(
                Icons.home_rounded,
                'Home',
                    () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage()))),
            _buildDrawerItem(
                Icons.dashboard_rounded, 'Dashboard', () => Navigator.pop(context)),
            _buildDrawerCategoryHeader('CORE MANAGEMENT'),
            _buildDrawerItem(
                Icons.apartment_rounded,
                'Projects',
                    () => _navigateToPage(const ProjectsPage()),
                badge: counts['projects']!.toString()),
            _buildDrawerItem(
                Icons.business_rounded,
                'Buildings',
                    () => _navigateToPage(const BuildingsPage()),
                badge: counts['buildings']!.toString()),
            _buildDrawerItem(
                Icons.layers_rounded,
                'Floors',
                    () => _navigateToPage(const FloorsPage()),
                badge: counts['floors']!.toString()),
            _buildDrawerItem(
                Icons.door_front_door_rounded,
                'Units',
                    () => _navigateToPage(const UnitsPage()),
                badge: counts['units']!.toString()),
            _buildDrawerCategoryHeader('FINANCIALS'),
            _buildDrawerItem(
                Icons.receipt_long_rounded,
                'Transactions',
                    () => _navigateToPage(const TransactionsPage()),
                badge: counts['transactions']!.toString()),
            _buildDrawerItem(Icons.book_online_rounded, 'Bookings',
                    () => _navigateToPage(const BookingsPage())),
            _buildDrawerCategoryHeader('RESOURCES'),
            _buildDrawerItem(
                Icons.people_rounded,
                'Employees',
                    () => _navigateToPage(const EmployeesPage()),
                badge: counts['employees']!.toString()),
            _buildDrawerItem(
                Icons.groups_rounded,
                'Customers',
                    () => _navigateToPage(const CustomersPage()),
                badge: counts['customers']!.toString()),
            _buildDrawerItem(Icons.inventory_rounded, 'Raw Materials',
                    () => _navigateToPage(const RawMaterialsPage())),
            _buildDrawerItem(
                Icons.construction_rounded,
                'Stages',
                    () => _navigateToPage(const StagesPage()),
                badge: counts['stages']!.toString()),
            const Divider(
                color: Colors.white24,
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16),
            _buildDrawerItem(Icons.analytics_rounded, 'Analytics', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(_buildComingSoonSnackBar('Analytics'));
            }),
            _buildDrawerItem(
                Icons.settings_rounded, 'Settings', () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Admin Panel',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildDrawerCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 16, bottom: 8, right: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _navigateToPage(Widget page) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page))
        .then((_) => _reloadData());
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {String? badge}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: (badge != null && badge != '0')
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: secondaryViolet, borderRadius: BorderRadius.circular(12)),
        child: Text(badge,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      )
          : null,
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  SnackBar _buildComingSoonSnackBar(String feature) {
    return SnackBar(
      content: Row(children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white),
        const SizedBox(width: 12),
        Text('$feature feature coming soon')
      ]),
      backgroundColor: secondaryViolet,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    );
  }

  Widget _buildStatsGrid() {
    final counts = _dataCounts;
    final currencyFormat =
    NumberFormat.compactCurrency(locale: 'en_US', symbol: '\$');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Projects', counts['projects']!.toString(),
            Icons.apartment_rounded, secondaryViolet, 'Active Projects'),
        _buildStatCard('Buildings', counts['buildings']!.toString(),
            Icons.business_rounded, primaryViolet, 'In Portfolio'),
        _buildStatCard('Employees', counts['employees']!.toString(),
            Icons.people_rounded, accentOrange, 'On Payroll'),
        _buildStatCard('Customers', counts['customers']!.toString(),
            Icons.groups_rounded, accentBlue, 'Total Clients'),
        _buildStatCard('Total Credit', currencyFormat.format(_totalCredit),
            Icons.arrow_upward_rounded, accentGreen, 'Income Recorded'),
        _buildStatCard('Total Debit', currencyFormat.format(_totalDebit),
            Icons.arrow_downward_rounded, accentRed, 'Expenses Paid'),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 22, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return _buildEmptyState("No recent transactions to display.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryViolet)),
            TextButton(
                onPressed: () => _navigateToPage(const TransactionsPage()),
                child: const Text('See All',
                    style: TextStyle(color: secondaryViolet))),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: _recentTransactions
              .map((transaction) => _buildTransactionItem(transaction))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? accentGreen : accentRed;
    final icon =
    isCredit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name ?? 'No Description',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryViolet),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.date != null
                      ? DateFormat('MMM dd, yyyy').format(transaction.date!)
                      : 'No Date',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$sign${currencyFormat.format(transaction.amount ?? 0.0)}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.logout_rounded, color: accentRed, size: 28),
        SizedBox(width: 12),
        Text('Confirm Logout')
      ]),
      content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 15)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          child: const Text('Cancel', style: TextStyle(fontSize: 15)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentRed,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Text(message)
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.red.shade300, size: 60),
            const SizedBox(height: 16),
            const Text('Connection Error',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Could not fetch dashboard data. Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryViolet,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}