import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/building.dart';
import '../models/floor.dart';
import '../services/building_service.dart';
import '../services/floor_service.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class FloorFormPage extends StatefulWidget {
  final Floor? floor;

  const FloorFormPage({Key? key, this.floor}) : super(key: key);

  @override
  State<FloorFormPage> createState() => _FloorFormPageState();
}

class _FloorFormPageState extends State<FloorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _expectedEndDate;
  Building? _selectedBuilding;
  List<Building> _buildings = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _populateForm() {
    final floor = widget.floor!;
    _nameController.text = floor.name ?? '';
    _expectedEndDate = floor.expectedEndDate;
    _selectedBuilding = floor.building;
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    try {
      final buildings = await BuildingService.getAllBuildings();
      if (mounted) {
        setState(() {
          _buildings = buildings;
          if (widget.floor != null) {
            _populateForm();
            // Ensure the selected building is the same object from the newly fetched list
            if (widget.floor!.building != null) {
              _selectedBuilding = _buildings.firstWhere((b) => b.id == widget.floor!.building!.id, orElse: () => _buildings.first);
            }
          }
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        _showErrorSnackBar('Failed to load buildings: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryViolet, onPrimary: Colors.white, onSurface: primaryViolet),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expectedEndDate) {
      setState(() => _expectedEndDate = picked);
    }
  }

  Future<void> _saveFloor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBuilding == null) {
      _showErrorSnackBar('Please select a building');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final floor = Floor(
        id: widget.floor?.id,
        name: _nameController.text.trim(),
        expectedEndDate: _expectedEndDate,
        building: _selectedBuilding,
      );

      final success = widget.floor == null ? await FloorService.createFloor(floor) : await FloorService.updateFloor(floor);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Floor saved successfully'), backgroundColor: accentGreen));
          Navigator.pop(context, true);
        } else {
          _showErrorSnackBar('Failed to save floor');
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: accentRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(widget.floor == null ? 'New Floor' : 'Edit Floor'),
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: primaryViolet))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Floor Details'),
              const SizedBox(height: 16),
              _buildTextField(controller: _nameController, label: 'Floor Name / Number', icon: Icons.layers_outlined, validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<Building>(
                value: _selectedBuilding,
                decoration: _buildInputDecoration('Building', Icons.business_rounded),
                items: _buildings.map((building) => DropdownMenuItem(value: building, child: Text(building.name ?? 'Unnamed Building'))).toList(),
                onChanged: (value) => setState(() => _selectedBuilding = value),
                validator: (value) => value == null ? 'Please select a building' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: _buildInputDecoration('Expected Completion Date', Icons.calendar_today_outlined, color: secondaryViolet),
                  child: Text(
                    _expectedEndDate != null ? DateFormat('MMMM dd, yyyy').format(_expectedEndDate!) : 'Not Set',
                    style: const TextStyle(fontSize: 16, color: secondaryViolet),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveFloor,
                  icon: _isLoading ? const SizedBox.shrink() : Icon(widget.floor == null ? Icons.add_circle_outline : Icons.check_circle_outline),
                  label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Text(widget.floor == null ? 'Create Floor' : 'Update Floor'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryViolet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {Color? color}) {
    final iconColor = color ?? primaryViolet;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: iconColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon),
      validator: validator,
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
}