// lib/pages/transactions_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../models/transaction.dart' as model;
import '../services/pdf_service.dart';
import '../services/transaction_service.dart';
import 'transaction_form_page.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<model.Transaction> transactions = [];
  List<model.Transaction> filteredTransactions = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  String _selectedTypeFilter = 'All';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<model.Transaction> tempFiltered = List.from(transactions);
    if (_selectedTypeFilter == 'Credit') {
      tempFiltered = tempFiltered.where((t) => t.isCredit).toList();
    } else if (_selectedTypeFilter == 'Debit') {
      tempFiltered = tempFiltered.where((t) => !t.isCredit).toList();
    }
    if (_selectedDateRange != null) {
      tempFiltered = tempFiltered.where((t) {
        if (t.date == null) return false;
        final transactionDate = DateTime(t.date!.year, t.date!.month, t.date!.day);
        final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final endDate = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
        return (transactionDate.isAfter(startDate) || transactionDate.isAtSameMomentAs(startDate)) &&
            (transactionDate.isBefore(endDate) || transactionDate.isAtSameMomentAs(endDate));
      }).toList();
    }
    if (query.isNotEmpty) {
      tempFiltered = tempFiltered.where((t) {
        return (t.name?.toLowerCase() ?? '').contains(query);
      }).toList();
    }
    setState(() {
      filteredTransactions = tempFiltered;
    });
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetched = await TransactionService.getAllTransactions();
      // --- FIX IS HERE: Made sorting null-safe ---
      fetched.sort((a, b) {
        // Treat null dates as the oldest
        final dateA = a.date ?? DateTime(1900);
        final dateB = b.date ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      // --- END OF FIX ---
      if (mounted) {
        setState(() {
          transactions = fetched;
          _applyFilters();
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = 'Failed to load transactions: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteTransaction(int id, String name) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => _buildDeleteDialog(name));
    if (confirmed == true && mounted) {
      final success = await TransactionService.deleteTransaction(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Transaction deleted successfully', Icons.check_circle, accentGreen));
          _loadTransactions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Failed to delete transaction', Icons.error, accentRed));
        }
      }
    }
  }

  Future<void> _pickDateRange() async {
    final initialDateRange = _selectedDateRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: initialDateRange,
    );
    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedTypeFilter = 'All';
      _selectedDateRange = null;
    });
    _applyFilters();
  }

  Future<void> _exportToPdf() async {
    if (filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildStatusSnackBar('No transactions to export', Icons.info_outline, Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryViolet)),
    );

    try {
      final String dateRangeString = _selectedDateRange != null
          ? '${DateFormat.yMd().format(_selectedDateRange!.start)} - ${DateFormat.yMd().format(_selectedDateRange!.end)}'
          : 'All Time';

      final pdfData = await PdfService.generateTransactionReport(
        transactions: filteredTransactions,
        dateRange: dateRangeString,
        filterType: _selectedTypeFilter,
      );

      Navigator.of(context).pop();

      await Printing.layoutPdf(
        onLayout: (format) async => pdfData,
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        _buildStatusSnackBar('Failed to generate PDF: $e', Icons.error, accentRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _exportToPdf,
            tooltip: 'Export to PDF',
          ),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadTransactions,
              tooltip: 'Refresh'
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionFormPage()));
          if (result == true) _loadTransactions();
        },
        backgroundColor: primaryViolet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet))
                : errorMessage != null
                ? _buildErrorWidget()
                : filteredTransactions.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) => _buildTransactionCard(filteredTransactions[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search, color: primaryViolet),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: backgroundLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Wrap(
                spacing: 8.0,
                children: [
                  _buildFilterChip('All', _selectedTypeFilter == 'All', () => setState(() { _selectedTypeFilter = 'All'; _applyFilters(); })),
                  _buildFilterChip('Credit', _selectedTypeFilter == 'Credit', () => setState(() { _selectedTypeFilter = 'Credit'; _applyFilters(); }), color: accentGreen),
                  _buildFilterChip('Debit', _selectedTypeFilter == 'Debit', () => setState(() { _selectedTypeFilter = 'Debit'; _applyFilters(); }), color: accentRed),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined, color: primaryViolet),
                onPressed: _pickDateRange,
                tooltip: 'Filter by Date',
              ),
            ],
          ),
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Chip(
                avatar: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  '${DateFormat.yMd().format(_selectedDateRange!.start)} - ${DateFormat.yMd().format(_selectedDateRange!.end)}',
                  style: const TextStyle(fontSize: 12),
                ),
                onDeleted: () {
                  setState(() => _selectedDateRange = null);
                  _applyFilters();
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onPressed, {Color? color}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      backgroundColor: Colors.grey[200],
      selectedColor: (color ?? primaryViolet).withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? (color ?? primaryViolet) : Colors.black87, fontWeight: FontWeight.w600),
      checkmarkColor: color ?? primaryViolet,
      shape: StadiumBorder(side: BorderSide(color: isSelected ? (color ?? primaryViolet) : Colors.grey[300]!)),
    );
  }

  Widget _buildTransactionCard(model.Transaction transaction) {
    final bool isCredit = transaction.isCredit;
    final Color typeColor = isCredit ? accentGreen : accentRed;
    final IconData typeIcon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final String sign = isCredit ? '+' : '-';
    final formattedDate = transaction.date != null ? DateFormat.yMMMMd().format(transaction.date!) : 'No Date';
    final formattedAmount = NumberFormat.currency(locale: 'en_US', symbol: '\$').format(transaction.amount ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.0, offset: const Offset(0, 4))],
          border: Border(left: BorderSide(color: typeColor, width: 5))
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionFormPage(transaction: transaction))).then((result) { if (result == true) _loadTransactions(); });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: typeColor.withOpacity(0.1), child: Icon(typeIcon, color: typeColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.name ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text('$sign $formattedAmount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: typeColor)),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionFormPage(transaction: transaction))).then((result) { if (result == true) _loadTransactions(); });
                    } else if (value == 'delete') {
                      _deleteTransaction(transaction.id!, transaction.name!);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: primaryViolet), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: accentRed), title: Text('Delete', style: TextStyle(color: accentRed)), dense: true, contentPadding: EdgeInsets.zero)),
                  ],
                  icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AlertDialog _buildDeleteDialog(String name) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.warning_amber_rounded, color: accentRed), SizedBox(width: 12), Text('Confirm Delete')]),
      content: Text('Are you sure you want to delete transaction "$name"?'),
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
      ElevatedButton.icon(onPressed: _loadTransactions, icon: const Icon(Icons.refresh), label: const Text('Retry'), style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white)),
    ])));
  }

  Widget _buildEmptyStateWidget() {
    bool hasActiveFilters = _selectedTypeFilter != 'All' || _selectedDateRange != null || _searchController.text.isNotEmpty;

    return Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(hasActiveFilters ? Icons.filter_alt_off_outlined : Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(transactions.isEmpty ? 'No transactions recorded yet' : 'No matching transactions found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(transactions.isEmpty ? 'Tap the + button to add your first one' : 'Try adjusting your search or date filters', style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
        if(hasActiveFilters) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text("Clear All Filters"),
              style: ElevatedButton.styleFrom(backgroundColor: secondaryViolet, foregroundColor: Colors.white)
          )
        ]
      ]),
    ));
  }
}