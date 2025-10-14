import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/employee.dart';
import '../models/project.dart';
import '../services/employee_service.dart';
import '../services/project_service.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class ProjectFormPage extends StatefulWidget {
  final Project? project;

  const ProjectFormPage({Key? key, this.project}) : super(key: key);

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _projectType = 'RESIDENTIAL';
  int? _selectedProjectManagerId;
  List<Employee> _projectManagers = [];
  bool _isLoading = false;
  bool _isLoadingManagers = true;
  DateTime? _startDate;
  DateTime? _expectedEndDate;

  final List<String> _projectTypes = ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'INFRASTRUCTURE', 'MIXED_USE'];

  final Map<String, IconData> _projectTypeIcons = {
    'RESIDENTIAL': Icons.home_work_outlined,
    'COMMERCIAL': Icons.store_mall_directory_outlined,
    'INDUSTRIAL': Icons.factory_outlined,
    'INFRASTRUCTURE': Icons.construction_outlined,
    'MIXED_USE': Icons.location_city_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadProjectManagers();
  }

  void _populateForm() {
    final project = widget.project!;
    _nameController.text = project.name ?? '';
    _budgetController.text = project.budget?.toString() ?? '';
    _descriptionController.text = project.description ?? '';
    _projectType = project.projectType ?? 'RESIDENTIAL';
    _startDate = project.startDate;
    _expectedEndDate = project.expectedEndDate;

    if (project.projectManager != null) {
      _selectedProjectManagerId = project.projectManager!.id;
    }
  }

  Future<void> _loadProjectManagers() async {
    setState(() => _isLoadingManagers = true);
    try {
      final managers = await EmployeeService.getEmployeesByRole('PROJECT_MANAGER');
      if (mounted) {
        setState(() {
          _projectManagers = managers;
          _isLoadingManagers = false;
        });
        if (widget.project != null) _populateForm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingManagers = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load project managers: $e'), backgroundColor: accentRed));
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_expectedEndDate ?? _startDate ?? DateTime.now()).add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryViolet,
              onPrimary: Colors.white,
              onSurface: primaryViolet,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_expectedEndDate != null && _expectedEndDate!.isBefore(_startDate!)) {
            _expectedEndDate = null;
          }
        } else {
          _expectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProjectManagerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(children: [Icon(Icons.error_outline, color: Colors.white), SizedBox(width: 12), Text('Please select a project manager')]),
          backgroundColor: accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final selectedManager = _projectManagers.firstWhere((manager) => manager.id == _selectedProjectManagerId);
        final project = Project(
          id: widget.project?.id,
          name: _nameController.text,
          budget: int.tryParse(_budgetController.text),
          startDate: _startDate,
          expectedEndDate: _expectedEndDate,
          projectType: _projectType,
          projectManager: selectedManager,
          description: _descriptionController.text,
        );

        final success = widget.project == null ? await ProjectService.createProject(project) : await ProjectService.updateProject(project);

        if (mounted) {
          setState(() => _isLoading = false);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 12), Text(widget.project == null ? 'Project created successfully' : 'Project updated successfully')]),
              backgroundColor: accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ));
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Row(children: [Icon(Icons.error_outline, color: Colors.white), SizedBox(width: 12), Expanded(child: Text('Failed to save project'))]),
              backgroundColor: accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ));
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text('Error: $e'))]),
            backgroundColor: accentRed,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      // --- UPDATED APP BAR ---
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        elevation: 2.0,
      ),
      body: _isLoadingManagers
          ? const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: primaryViolet), SizedBox(height: 16), Text('Loading project managers...')]),
      )
          : SingleChildScrollView(
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Icon(_projectTypeIcons[_projectType] ?? Icons.apartment, size: 60, color: primaryViolet),
          ),
          const SizedBox(height: 16),
          Text(widget.project == null ? 'Create New Project' : 'Update Project', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.project == null ? 'Fill in the details below' : 'Modify project information', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
            _buildSectionTitle('Project Information'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nameController, label: 'Project Name', icon: Icons.apartment_outlined, validator: (v) => v == null || v.isEmpty ? 'Please enter project name' : null),
            const SizedBox(height: 16),
            _buildProjectTypeDropdown(),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _budgetController,
                label: 'Budget (\$)',
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Please enter budget' : (int.tryParse(v) == null ? 'Please enter a valid number' : null)),
            const SizedBox(height: 16),
            _buildProjectManagerDropdown(),
            const SizedBox(height: 24),
            _buildSectionTitle('Timeline'),
            const SizedBox(height: 16),
            _buildDateSelector(label: 'Start Date', date: _startDate, onTap: () => _selectDate(context, true), icon: Icons.calendar_today_outlined, color: primaryViolet),
            const SizedBox(height: 16),
            _buildDateSelector(label: 'Expected End Date', date: _expectedEndDate, onTap: () => _selectDate(context, false), icon: Icons.event_outlined, color: secondaryViolet),
            const SizedBox(height: 24),
            _buildSectionTitle('Description'),
            const SizedBox(height: 16),
            _buildTextField(controller: _descriptionController, label: 'Project Description', icon: Icons.description_outlined, maxLines: 5),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryViolet,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryViolet.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.project == null ? Icons.add_circle_outline : Icons.save_outlined),
          const SizedBox(width: 8),
          Text(widget.project == null ? 'Create Project' : 'Update Project', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ]),
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

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: primaryViolet),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2)),
      ),
      validator: validator,
    );
  }

  Widget _buildProjectTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _projectType,
      decoration: InputDecoration(
        labelText: 'Project Type',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(_projectTypeIcons[_projectType] ?? Icons.category_outlined, color: primaryViolet),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _projectTypes.map((type) => DropdownMenuItem(value: type, child: Row(children: [Icon(_projectTypeIcons[type], size: 20, color: primaryViolet), const SizedBox(width: 12), Text(type.replaceAll('_', ' '))]))).toList(),
      onChanged: (value) => setState(() => _projectType = value!),
    );
  }

  Widget _buildProjectManagerDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedProjectManagerId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Project Manager',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.person_outline, color: primaryViolet),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _projectManagers.map((manager) => DropdownMenuItem<int>(value: manager.id, child: Text(manager.name ?? 'N/A', overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (value) => setState(() => _selectedProjectManagerId = value),
      validator: (value) => value == null ? 'Please select a project manager' : null,
    );
  }

  Widget _buildDateSelector({required String label, required DateTime? date, required VoidCallback onTap, required IconData icon, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(date != null ? DateFormat('MMMM dd, yyyy').format(date) : 'Select Date', style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}