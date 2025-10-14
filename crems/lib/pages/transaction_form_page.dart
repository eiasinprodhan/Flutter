// lib/pages/transaction_form_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add `intl: ^0.18.0` to pubspec.yaml
import '../models/transaction.dart' as model;
import '../services/transaction_service.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class TransactionFormPage extends StatefulWidget {
  final model.Transaction? transaction;

  const TransactionFormPage({Key? key, this.transaction}) : super(key: key);

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isCredit = false; // false = Debit/Expense, true = Credit/Income
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) _populateForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final t = widget.transaction!;
    _nameController.text = t.name ?? '';
    _amountController.text = t.amount?.toString() ?? '';
    _selectedDate = t.date ?? DateTime.now();
    _isCredit = t.isCredit;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final transaction = model.Transaction(
          id: widget.transaction?.id,
          name: _nameController.text.trim(),
          amount: double.tryParse(_amountController.text.trim()),
          date: _selectedDate,
          isCredit: _isCredit,
        );

        bool success;
        if (widget.transaction == null) {
          success = await TransactionService.createTransaction(transaction);
        } else {
          success = await TransactionService.updateTransaction(transaction);
        }

        if (mounted) {
          _showStatusSnackBar(success ? 'Transaction saved successfully' : 'Failed to save transaction.', success);
          if (success) Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) _showErrorSnackBar('Error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar(message, Icons.error_outline, accentRed));
  }

  void _showStatusSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar(message, success ? Icons.check_circle : Icons.error_outline, success ? accentGreen : accentRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'), backgroundColor: primaryViolet, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Transaction Details'),
            const SizedBox(height: 16),
            _buildTransactionTypeSelector(),
            const SizedBox(height: 16),
            _buildTextField(_nameController, 'Transaction Name (e.g., Salary, Rent)', Icons.label_outline, validator: (v) => v!.trim().isEmpty ? 'Please enter a name' : null),
            const SizedBox(height: 16),
            _buildTextField(_amountController, 'Amount', Icons.attach_money, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.trim().isEmpty || double.tryParse(v) == null ? 'Enter a valid amount' : null),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveTransaction,
                icon: _isLoading ? const SizedBox.shrink() : Icon(widget.transaction == null ? Icons.add_circle_outline : Icons.save_outlined),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Text(widget.transaction == null ? 'Add Transaction' : 'Update Transaction'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Center(
      child: ToggleButtons(
        isSelected: [_isCredit, !_isCredit],
        onPressed: (index) {
          setState(() => _isCredit = index == 0);
        },
        borderRadius: BorderRadius.circular(12),
        selectedColor: Colors.white,
        fillColor: _isCredit ? accentGreen.withOpacity(0.8) : accentRed.withOpacity(0.8),
        selectedBorderColor: _isCredit ? accentGreen : accentRed,
        borderColor: Colors.grey[300],
        children: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Row(children: [Icon(Icons.arrow_downward), SizedBox(width: 8), Text('Credit (Income)')])),
          Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Row(children: [Icon(Icons.arrow_upward), SizedBox(width: 8), Text('Debit (Expense)')])),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration('Date', Icons.calendar_today_outlined).copyWith(
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[350]!))
        ),
        child: Text(DateFormat.yMMMMd().format(_selectedDate), style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [primaryViolet, secondaryViolet]), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType, bool obscureText = false, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c, keyboardType: keyboardType, obscureText: obscureText, maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: primaryViolet)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2.0)),
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }
}