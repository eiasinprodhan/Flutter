import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import 'booking_form_page.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<Booking> _allBookings = [];
  List<Booking> _filteredBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final bookings = await BookingService.getAllBookings();
      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _filteredBookings = bookings;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to load bookings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBookings = _allBookings.where((booking) {
        final customerNameMatch = booking.customer?.name?.toLowerCase().contains(query) ?? false;
        final unitNumberMatch = booking.unit?.unitNumber?.toLowerCase().contains(query) ?? false;
        final buildingNameMatch = booking.building?.name?.toLowerCase().contains(query) ?? false;
        return customerNameMatch || unitNumberMatch || buildingNameMatch;
      }).toList();
    });
  }

  Future<void> _deleteBooking(int id, String name) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => _buildDeleteDialog(name));
    if (confirmed == true && mounted) {
      final success = await BookingService.deleteBooking(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar(
          success ? 'Booking deleted successfully' : 'Failed to delete booking',
          success ? Icons.check_circle : Icons.error,
          success ? accentGreen : accentRed,
        ));
        if (success) _loadBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        title: const Text('Bookings'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings, tooltip: 'Refresh')],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFormPage()));
          if (result == true) _loadBookings();
        },
        label: const Text('New Booking', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryViolet,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet))
                : _errorMessage != null
                ? _buildErrorWidget()
                : _filteredBookings.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _filteredBookings.length,
              itemBuilder: (context, index) => _buildBookingCard(_filteredBookings[index]),
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
          hintText: 'Search by Customer, Unit, or Building...',
          prefixIcon: const Icon(Icons.search, color: primaryViolet),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: backgroundLight,
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.receipt_long_outlined, color: primaryViolet, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.customer?.name ?? 'No Customer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
                          const SizedBox(height: 4),
                          Text('Unit #${booking.unit?.unitNumber ?? 'N/A'} in ${booking.building?.name ?? 'N/A'}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormPage(booking: booking))).then((result) { if (result == true) _loadBookings(); });
                        } else if (value == 'delete') {
                          _deleteBooking(booking.id!, "Booking #${booking.id}");
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: primaryViolet), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
                        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: accentRed), title: Text('Delete', style: TextStyle(color: accentRed)), dense: true, contentPadding: EdgeInsets.zero)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(Icons.calendar_today_outlined, booking.date != null ? DateFormat.yMMMd().format(booking.date!) : 'N/A'),
                    if(booking.isLoan)
                      _buildInfoChip(Icons.real_estate_agent_outlined, 'LOAN', color: Colors.white)
                    else
                      _buildInfoChip(Icons.money_off, 'CASH', color: accentGreen),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    currencyFormat.format(booking.amount ?? 0),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryViolet),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    final chipColor = color ?? Colors.grey.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: chipColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: chipColor)),
        ],
      ),
    );
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: _loadBookings, icon: const Icon(Icons.refresh), label: const Text('Retry'), style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_online_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_allBookings.isEmpty ? 'No bookings found' : 'No matching bookings', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(_allBookings.isEmpty ? 'Add your first booking to get started' : 'Try adjusting your search filter', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}