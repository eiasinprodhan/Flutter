import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/employee_card.dart';
import 'add_employee_screen.dart';
import 'edit_employee_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  String searchQuery = '';
  String selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveHelper.isDesktop(context)) {
            return _buildDesktopLayout();
          } else if (ResponsiveHelper.isTablet(context)) {
            return _buildTabletLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  // ============================================
  // LAYOUT BUILDERS
  // ============================================

  Widget _buildMobileLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  margin: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // APP BAR
  // ============================================

  Widget _buildAppBar() {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Employees',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Employee Count Badge
          Consumer<EmployeeProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.employees.length} Total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Refresh Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
              },
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CONTENT
  // ============================================

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildRoleFilter(),
        const SizedBox(height: 16),
        Expanded(child: _buildEmployeeList()),
      ],
    );
  }

  // ============================================
  // SEARCH BAR
  // ============================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by name, email, phone or role...',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
              },
              tooltip: 'Clear search',
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // ROLE FILTER
  // ============================================

  Widget _buildRoleFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('All'),
          ...AppConstants.roles.map((role) => _buildFilterChip(role)).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String role) {
    final isSelected = selectedRole == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(AppConstants.formatRole(role)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedRole = role;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 0 : 1,
          ),
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: AppColors.primary.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // ============================================
  // EMPLOYEE LIST
  // ============================================

  Widget _buildEmployeeList() {
    return Consumer<EmployeeProvider>(
      builder: (context, provider, child) {
        // Loading State
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading employees...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Error State
        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Employees',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadEmployees(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        var employees = provider.employees;

        // Apply Search Filter
        if (searchQuery.isNotEmpty) {
          employees = employees.where((emp) {
            final query = searchQuery.toLowerCase();
            return emp.name.toLowerCase().contains(query) ||
                emp.email.toLowerCase().contains(query) ||
                emp.phone.contains(query) ||
                emp.role.toLowerCase().contains(query);
          }).toList();
        }

        // Apply Role Filter
        if (selectedRole != 'All') {
          employees = employees.where((emp) => emp.role == selectedRole).toList();
        }

        // Empty State
        if (employees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty || selectedRole != 'All'
                      ? 'No employees found'
                      : 'No employees yet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  searchQuery.isNotEmpty || selectedRole != 'All'
                      ? 'Try adjusting your search or filters'
                      : 'Tap the + button to add employees',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Employee List/Grid
        return RefreshIndicator(
          onRefresh: () => provider.loadEmployees(),
          color: AppColors.primary,
          child: ResponsiveHelper.isDesktop(context)
              ? _buildDesktopGrid(employees)
              : _buildMobileList(employees),
        );
      },
    );
  }

  // ============================================
  // MOBILE LIST VIEW
  // ============================================

  Widget _buildMobileList(List<dynamic> employees) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 10),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return EmployeeCard(
          employee: employee,
          onTap: () {
            _showEmployeeDetails(employee);
          },
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditEmployeeScreen(employee: employee),
              ),
            ).then((value) {
              if (value == true) {
                Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
              }
            });
          },
          onDelete: () => _confirmDelete(employee.id!),
        );
      },
    );
  }

  // ============================================
  // DESKTOP GRID VIEW
  // ============================================

  Widget _buildDesktopGrid(List<dynamic> employees) {
    return GridView.builder(
      padding: const EdgeInsets.all(20).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return EmployeeCard(
          employee: employee,
          onTap: () => _showEmployeeDetails(employee),
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditEmployeeScreen(employee: employee),
              ),
            ).then((value) {
              if (value == true) {
                Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
              }
            });
          },
          onDelete: () => _confirmDelete(employee.id!),
        );
      },
    );
  }

  // ============================================
  // FLOATING ACTION BUTTON
  // ============================================

  Widget _buildFloatingActionButtons() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddEmployeeScreen(),
          ),
        ).then((value) {
          if (value == true) {
            Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
          }
        });
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add),
      label: const Text('Add Employee'),
    );
  }

  // ============================================
  // EMPLOYEE DETAILS DIALOG
  // ============================================

  void _showEmployeeDetails(employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary,
              child: Text(
                employee.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    AppConstants.formatRole(employee.role),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.email, 'Email', employee.email),
              _buildDetailRow(Icons.phone, 'Phone', employee.phone),
              _buildDetailRow(Icons.badge, 'NID', employee.nid.toString()),
              _buildDetailRow(Icons.location_on, 'Address', employee.address),
              _buildDetailRow(Icons.flag, 'Country', employee.country),
              _buildDetailRow(Icons.payments, 'Salary', '\$${employee.salary}'),
              _buildDetailRow(Icons.payment, 'Salary Type', employee.salaryType),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DELETE CONFIRMATION
  // ============================================

  Future<void> _confirmDelete(int id) async {
    print('\n╔════════════════════════════════════════╗');
    print('║  UI - DELETE CONFIRMATION              ║');
    print('╚════════════════════════════════════════╝');
    print('🔵 Employee ID to delete: $id');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Employee',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this employee?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Employee ID: $id',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ User cancelled delete');
              Navigator.pop(context, false);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('✅ User confirmed delete');
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      print('🟡 Proceeding with delete operation for ID: $id\n');

      // Show loading dialog
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 20),
                Text(
                  'Deleting employee...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      final success = await provider.deleteEmployee(id);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      print('🟢 Delete operation completed. Success: $success\n');

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Employee deleted successfully',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          final errorMsg = provider.errorMessage ?? 'Failed to delete employee';
          print('❌ Delete failed with error: $errorMsg');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Delete Failed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMsg,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _confirmDelete(id),
              ),
            ),
          );
        }
      }
    } else {
      print('⚪ Delete cancelled by user');
      print('╚════════════════════════════════════════╝\n');
    }
  }
}