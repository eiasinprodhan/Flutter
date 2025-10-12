import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/building.dart';
import '../models/floor.dart';
import '../services/building_service.dart';
import '../services/floor_service.dart';

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
    if (widget.floor != null) {
      _populateForm();
    }
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
      setState(() {
        _buildings = buildings;
        // If editing, ensure the selected building is in the list
        if (widget.floor?.building != null) {
          _selectedBuilding = _buildings.firstWhere((b) => b.id == widget.floor!.building!.id);
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load buildings: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _expectedEndDate) {
      setState(() {
        _expectedEndDate = picked;
      });
    }
  }

  Future<void> _saveFloor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedBuilding == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a building'), backgroundColor: Colors.red),
      );
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

      final success = widget.floor == null
          ? await FloorService.createFloor(floor)
          : await FloorService.updateFloor(floor);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Floor saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save floor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.floor == null ? 'New Floor' : 'Edit Floor'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Floor Details'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: 'Floor Name / Number',
                icon: Icons.layers,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Building>(
                value: _selectedBuilding,
                decoration: _buildInputDecoration(
                    'Building', Icons.business_rounded),
                items: _buildings
                    .map((building) => DropdownMenuItem(
                  value: building,
                  child: Text(building.name ?? 'Unnamed Building'),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBuilding = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a building' : null,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: _buildInputDecoration('Expected Completion Date', Icons.calendar_today),
                  child: Text(
                    _expectedEndDate != null
                        ? DateFormat('MMMM dd, yyyy').format(_expectedEndDate!)
                        : 'Not Set',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveFloor,
                  icon: _isLoading ? Container() : Icon(widget.floor == null ? Icons.add : Icons.check),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.floor == null ? 'Create Floor' : 'Update Floor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon),
      validator: validator,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A237E),
      ),
    );
  }
}