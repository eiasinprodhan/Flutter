import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/floor.dart';
import '../models/stage.dart';
import '../services/employee_service.dart';
import '../services/floor_service.dart';
import '../services/stage_service.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class StageFormPage extends StatefulWidget {
  final Stage? stage;

  const StageFormPage({Key? key, this.stage}) : super(key: key);

  @override
  State<StageFormPage> createState() => _StageFormPageState();
}

class _StageFormPageState extends State<StageFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  Floor? _selectedFloor;
  List<int> _selectedLabourIds = [];

  List<Floor> _floors = [];
  List<Employee> _labours = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _populateForm() {
    final stage = widget.stage!;
    _nameController.text = stage.name ?? '';
    _startDate = stage.startDate;
    _endDate = stage.endDate;
    _selectedFloor = stage.floor;
    _selectedLabourIds = stage.labours ?? [];
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    try {
      final results = await Future.wait([
        FloorService.getAllFloors(),
        EmployeeService.getEmployeesByRole('LABOUR'),
      ]);
      if (mounted) {
        setState(() {
          _floors = results[0] as List<Floor>;
          _labours = results[1] as List<Employee>;
          if (widget.stage != null) {
            _populateForm();
            if (widget.stage!.floor != null) {
              _selectedFloor = _floors.firstWhere((f) => f.id == widget.stage!.floor!.id);
            }
          }
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        _showErrorSnackBar('Failed to load data: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now()).add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryViolet, onPrimary: Colors.white)), child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showLabourSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Labours'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: _labours.length,
                  itemBuilder: (context, index) {
                    final labour = _labours[index];
                    final isSelected = _selectedLabourIds.contains(labour.id);
                    return CheckboxListTile(
                      title: Text(labour.name ?? 'N/A'),
                      value: isSelected,
                      activeColor: primaryViolet,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedLabourIds.add(labour.id!);
                          } else {
                            _selectedLabourIds.remove(labour.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
            );
          },
        );
      },
    ).then((_) => setState(() {}));
  }

  Future<void> _saveStage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final stage = Stage(
        id: widget.stage?.id,
        name: _nameController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        floor: _selectedFloor,
        labours: _selectedLabourIds,
      );
      final success = widget.stage == null ? await StageService.createStage(stage) : await StageService.updateStage(stage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stage saved successfully'), backgroundColor: accentGreen));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error: $e');
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
        title: Text(widget.stage == null ? 'New Stage' : 'Edit Stage'),
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
              _buildSectionTitle('Stage Details'),
              const SizedBox(height: 16),
              _buildTextField(controller: _nameController, label: 'Stage Name (e.g., Foundation)', icon: Icons.construction_outlined, validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<Floor>(
                value: _selectedFloor,
                decoration: _buildInputDecoration('Assign to Floor', Icons.layers_outlined),
                items: _floors.map((f) => DropdownMenuItem(value: f, child: Text('${f.name} (${f.building?.name})'))).toList(),
                onChanged: (v) => setState(() => _selectedFloor = v),
                validator: (v) => v == null ? 'Floor is required' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Timeline'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDateSelector('Start Date', true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateSelector('End Date', false)),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Assign Labours'),
              const SizedBox(height: 16),
              InkWell(
                onTap: _showLabourSelectionDialog,
                child: InputDecorator(
                  decoration: _buildInputDecoration('Assigned Labours', Icons.groups_outlined),
                  child: Text(_selectedLabourIds.isEmpty ? 'No labours assigned' : '${_selectedLabourIds.length} labour(s) assigned', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveStage,
                  icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save_outlined),
                  label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Text(widget.stage == null ? 'Create Stage' : 'Update Stage'),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, bool isStart) {
    DateTime? date = isStart ? _startDate : _endDate;
    return InkWell(
      onTap: () => _selectDate(context, isStart),
      child: InputDecorator(
        decoration: _buildInputDecoration(label, Icons.calendar_today_outlined, color: secondaryViolet),
        child: Text(
          date != null ? DateFormat.yMMMd().format(date) : 'Not Set',
          style: const TextStyle(fontSize: 16, color: secondaryViolet),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {Color? color}) {
    final iconColor = color ?? primaryViolet;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: iconColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2.0)),
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