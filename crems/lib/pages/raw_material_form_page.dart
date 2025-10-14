// lib/pages/raw_material_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/raw_material.dart';
import '../services/raw_material_service.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class RawMaterialFormPage extends StatefulWidget {
  final RawMaterial? material;

  const RawMaterialFormPage({Key? key, this.material}) : super(key: key);

  @override
  State<RawMaterialFormPage> createState() => _RawMaterialFormPageState();
}

class _RawMaterialFormPageState extends State<RawMaterialFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.material != null) _populateForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final m = widget.material!;
    _nameController.text = m.name ?? '';
    _quantityController.text = m.quantity?.toString() ?? '';
    _unitController.text = m.unit ?? '';
  }

  Future<void> _saveMaterial() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final material = RawMaterial(
          id: widget.material?.id,
          name: _nameController.text.trim(),
          quantity: int.tryParse(_quantityController.text.trim()),
          unit: _unitController.text.trim(),
        );

        bool success;
        if (widget.material == null) {
          success = await RawMaterialService.createRawMaterial(material);
        } else {
          success = await RawMaterialService.updateRawMaterial(material);
        }

        if (mounted) {
          _showStatusSnackBar(success ? (widget.material == null ? 'Material created successfully' : 'Material updated successfully') : 'Failed to save material.', success);
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
      appBar: AppBar(title: Text(widget.material == null ? 'Add Raw Material' : 'Edit Raw Material'), backgroundColor: primaryViolet, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primaryViolet, secondaryViolet])),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 16),
          Text(
            widget.material == null ? 'Creating New Material' : 'Editing ${widget.material!.name}',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
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
            _buildSectionTitle('Material Information'),
            const SizedBox(height: 16),
            _buildTextField(_nameController, 'Material Name', Icons.label_outline, validator: (v) => v!.trim().isEmpty ? 'Please enter a name' : null),
            const SizedBox(height: 16),
            _buildTextField(_quantityController, 'Initial Quantity', Icons.format_list_numbered, keyboardType: TextInputType.number, validator: (v) => v!.trim().isEmpty || int.tryParse(v) == null ? 'Enter a valid number' : null),
            const SizedBox(height: 16),
            _buildTextField(_unitController, 'Unit (e.g., kg, pcs, liter)', Icons.straighten_outlined, validator: (v) => v!.trim().isEmpty ? 'Please enter a unit' : null),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveMaterial,
                icon: _isLoading ? const SizedBox.shrink() : Icon(widget.material == null ? Icons.add_circle_outline : Icons.save_outlined),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Text(widget.material == null ? 'Create Material' : 'Update Material'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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