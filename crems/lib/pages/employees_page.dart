import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import 'employee_form_page.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({Key? key}) : super(key: key);

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String? selectedRole;

  final List<String> roles = [
    'All',
    'ADMIN',
    'PROJECT_MANAGER',
    'SITE_MANAGER',
    'LABOUR',
  ];

  final Map<String, Color> roleColors = {
    'ADMIN': const Color(0xFFFF6B6B),
    'PROJECT_MANAGER': const Color(0xFF1A237E),
    'SITE_MANAGER': const Color(0xFF00BFA5),
    'LABOUR': const Color(0xFFFFB74D),
  };

  final Map<String, IconData> roleIcons = {
    'ADMIN': Icons.admin_panel_settings,
    'PROJECT_MANAGER': Icons.engineering,
    'SITE_MANAGER': Icons.construction,
    'LABOUR': Icons.handyman,
  };

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredEmployees = employees.where((employee) {
        final matchesSearch = (employee.name?.toLowerCase() ?? '').contains(query) ||
            (employee.email?.toLowerCase() ?? '').contains(query) ||
            (employee.role ?? '').toLowerCase().contains(query) ||
            (employee.phone ?? '').toLowerCase().contains(query);

        final matchesRole = selectedRole == null ||
            selectedRole == 'All' ||
            employee.role == selectedRole;

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  void _filterByRole(String? role) {
    setState(() {
      selectedRole = role;
      _applyFilters();
    });
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedEmployees = await EmployeeService.getAllEmployees();
      if (mounted) {
        setState(() {
          employees = fetchedEmployees;
          filteredEmployees = fetchedEmployees;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load employees: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteEmployee(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 12),
            Text('Confirm Delete'),
          ],
        ),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await EmployeeService.deleteEmployee(id);

      // **FIX:** Always check if the widget is still in the tree
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Employee deleted successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _loadEmployees();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Failed to delete employee')),
                ],
              ),
              backgroundColor: const Color(0xFFFF6B6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  String _getImageUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return '';
    }
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    return 'http://localhost:8080/images/employees/$photoPath';
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  int _getDaysSinceJoining(DateTime? joiningDate) {
    if (joiningDate == null) return 0;
    return DateTime.now().difference(joiningDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains unchanged as it was already well-structured.
    // All previous UI code is correct.
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Employees'),
            Text(
              '${filteredEmployees.length} employee${filteredEmployees.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeFormPage(),
            ),
          );
          if (result == true) {
            _loadEmployees();
          }
        },
        backgroundColor: const Color(0xFF00BFA5),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          // Role Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list,
                        size: 18, color: Color(0xFF1A237E)),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter by Role:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: roles.map((role) {
                      final isSelected = selectedRole == role ||
                          (selectedRole == null && role == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(role.replaceAll('_', ' ')),
                          selected: isSelected,
                          onSelected: (selected) {
                            _filterByRole(role == 'All' ? null : role);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: _getRoleColor(role).withOpacity(0.2),
                          checkmarkColor: _getRoleColor(role),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? _getRoleColor(role)
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? _getRoleColor(role)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Employee List
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00BFA5),
              ),
            )
                : errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadEmployees,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : filteredEmployees.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    employees.isEmpty
                        ? 'No employees found'
                        : 'No matching employees',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    employees.isEmpty
                        ? 'Add your first employee to get started'
                        : 'Try adjusting your search or filters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (employees.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _filterByRole(null);
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return _buildEmployeeCard(employee);
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    return roleColors[role] ?? const Color(0xFF757575);
  }

  Widget _buildEmployeeCard(Employee employee) {
    final imageUrl = _getImageUrl(employee.photo);
    final daysSinceJoining = _getDaysSinceJoining(employee.joiningDate);
    final isLongTerm = daysSinceJoining > 365;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getRoleColor(employee.role ?? '').withOpacity(0.8),
                          _getRoleColor(employee.role ?? ''),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildAvatarFallback(employee),
                      )
                          : _buildAvatarFallback(employee),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(employee.role ?? '')
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                roleIcons[employee.role] ?? Icons.person,
                                size: 14,
                                color: _getRoleColor(employee.role ?? ''),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (employee.role ?? 'N/A').replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getRoleColor(employee.role ?? ''),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildActionButton(Icons.edit, const Color(0xFF1A237E), 'Edit',
                              () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EmployeeFormPage(employee: employee),
                              ),
                            );
                            if (result == true) {
                              _loadEmployees();
                            }
                          }),
                      const SizedBox(height: 8),
                      _buildActionButton(Icons.delete, const Color(0xFFFF6B6B), 'Delete',
                              () => _deleteEmployee(employee.id!, employee.name!)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(Icons.email_outlined,
                        employee.email ?? 'No Email'),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.phone_outlined,
                      employee.phone ?? 'No Phone'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      Icons.attach_money,
                      'Salary',
                      _formatCurrency(employee.salary),
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      Icons.calendar_today,
                      'Joined',
                      _formatDate(employee.joiningDate),
                      const Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
              if (employee.joiningDate != null) ...[
                const SizedBox(height: 12),
                _buildTenureIndicator(isLongTerm, daysSinceJoining, employee.status),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(Employee employee) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: Text(
        employee.name?.substring(0, 1).toUpperCase() ?? 'E',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTenureIndicator(bool isLongTerm, int daysSinceJoining, bool? status) {
    final tenureColor = isLongTerm ? const Color(0xFF4CAF50) : const Color(0xFF00BFA5);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tenureColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isLongTerm ? Icons.emoji_events : Icons.access_time,
            color: tenureColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLongTerm
                  ? '${(daysSinceJoining / 365).floor()} year${(daysSinceJoining / 365).floor() > 1 ? 's' : ''} with company'
                  : '$daysSinceJoining days with company',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tenureColor,
              ),
            ),
          ),
          if (status == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}