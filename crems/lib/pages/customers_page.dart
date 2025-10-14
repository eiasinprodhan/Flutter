import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import 'customer_form_page.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
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
      filteredCustomers = customers.where((customer) {
        final matchesSearch = (customer.name?.toLowerCase() ?? '').contains(query) || (customer.email?.toLowerCase() ?? '').contains(query) || (customer.phone?.toLowerCase() ?? '').contains(query);
        return matchesSearch;
      }).toList();
    });
  }

  Future<void> _loadCustomers() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetchedCustomers = await CustomerService.getAllCustomers();
      if (mounted) {
        setState(() {
          customers = fetchedCustomers;
          filteredCustomers = fetchedCustomers;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = 'Failed to load customers: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteCustomer(int id, String name) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => _buildDeleteDialog(name));
    if (confirmed == true && mounted) {
      final success = await CustomerService.deleteCustomer(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Customer deleted successfully', Icons.check_circle, accentGreen));
          _loadCustomers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Failed to delete customer', Icons.error, accentRed));
        }
      }
    }
  }

  String _getImageUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return '';
    if (photoPath.startsWith('http')) return photoPath;
    return 'http://localhost:8080/images/customers/$photoPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customers'),
            if (!isLoading) Text('${filteredCustomers.length} customer${filteredCustomers.length != 1 ? 's' : ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCustomers, tooltip: 'Refresh')],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerFormPage()));
          if (result == true) _loadCustomers();
        },
        backgroundColor: primaryViolet,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Add Customer', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet))
                : errorMessage != null
                ? _buildErrorWidget()
                : filteredCustomers.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) => _buildCustomerCard(filteredCustomers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, email, phone...',
          prefixIcon: const Icon(Icons.search, color: primaryViolet),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: backgroundLight,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final imageUrl = _getImageUrl(customer.photo);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20.0, spreadRadius: 4.0, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: secondaryViolet.withOpacity(0.2),
                      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      onBackgroundImageError: (_, __) {},
                      child: imageUrl.isEmpty ? _buildAvatarFallback(customer, secondaryViolet) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.name ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
                          const SizedBox(height: 6),
                          _buildInfoChip(Icons.email_outlined, customer.email ?? 'No Email'),
                          const SizedBox(height: 4),
                          _buildInfoChip(Icons.phone_outlined, customer.phone ?? 'No Phone'),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerFormPage(customer: customer))).then((result) { if (result == true) _loadCustomers(); });
                        } else if (value == 'delete') {
                          _deleteCustomer(customer.id!, customer.name!);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: primaryViolet), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
                        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: accentRed), title: Text('Delete', style: TextStyle(color: accentRed)), dense: true, contentPadding: EdgeInsets.zero)),
                      ],
                      icon: const Icon(Icons.more_vert, color: primaryViolet),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(Customer customer, Color color) {
    return Center(child: Text(customer.name != null && customer.name!.isNotEmpty ? customer.name![0].toUpperCase() : 'C', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)));
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 6),
      Flexible(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
    ]);
  }

  AlertDialog _buildDeleteDialog(String name) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.warning_amber_rounded, color: accentRed), SizedBox(width: 12), Text('Confirm Delete')]),
      content: Text('Are you sure you want to delete "$name"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: Colors.white), child: const Text('Delete')),
      ],
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }

  Widget _buildErrorWidget() {
    return Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
      const SizedBox(height: 16),
      Text(errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 16), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: _loadCustomers, icon: const Icon(Icons.refresh), label: const Text('Retry'), style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white)),
    ])));
  }

  Widget _buildEmptyStateWidget() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
      const SizedBox(height: 16),
      Text(customers.isEmpty ? 'No customers found' : 'No matching customers', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Text(customers.isEmpty ? 'Add your first customer to get started' : 'Try adjusting your search filter', style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
    ],
    ));
  }
}