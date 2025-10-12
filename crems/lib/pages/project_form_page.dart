import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/project.dart';
import '../services/employee_service.dart';
import '../services/project_service.dart';

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
  Employee? _selectedProjectManager;
  List<Employee> _projectManagers = [];
  bool _isLoading = false;
  bool _isLoadingManagers = true;
  DateTime? _startDate;
  DateTime? _expectedEndDate;

  final List<String> _projectTypes = [
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'INFRASTRUCTURE',
    'MIXED_USE',
  ];

  final Map<String, IconData> _projectTypeIcons = {
    'RESIDENTIAL': Icons.home,
    'COMMERCIAL': Icons.business,
    'INDUSTRIAL': Icons.factory,
    'INFRASTRUCTURE': Icons.construction,
    'MIXED_USE': Icons.location_city,
  };

  @override
  void initState() {
    super.initState();
    _loadProjectManagers();
    if (widget.project != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final project = widget.project!;
    _nameController.text = project.name ?? '';
    _budgetController.text = project.budget?.toString() ?? '';
    _descriptionController.text = project.description ?? '';
    _projectType = project.projectType ?? 'RESIDENTIAL';
    _startDate = project.startDate;
    _expectedEndDate = project.expectedEndDate;
    _selectedProjectManager = project.projectManager;
  }

  Future<void> _loadProjectManagers() async {
    setState(() {
      _isLoadingManagers = true;
    });

    try {
      final managers = await EmployeeService.getEmployeesByRole('PROJECT_MANAGER');
      setState(() {
        _projectManagers = managers;
        _isLoadingManagers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingManagers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load project managers: $e'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_expectedEndDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A237E),
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
        } else {
          _expectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProjectManager == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Please select a project manager'),
              ],
            ),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final project = Project(
          id: widget.project?.id,
          name: _nameController.text,
          budget: int.tryParse(_budgetController.text),
          startDate: _startDate,
          expectedEndDate: _expectedEndDate,
          projectType: _projectType,
          projectManager: _selectedProjectManager,
          description: _descriptionController.text,
        );

        bool success;
        if (widget.project == null) {
          success = await ProjectService.createProject(project);
        } else {
          success = await ProjectService.updateProject(project);
        }

        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(widget.project == null
                      ? 'Project created successfully'
                      : 'Project updated successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Failed to save project')),
                ],
              ),
              backgroundColor: const Color(0xFFFF6B6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A237E),
                    const Color(0xFF00BFA5).withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _projectTypeIcons[_projectType] ?? Icons.apartment,
                      size: 60,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.project == null ? 'Create New Project' : 'Update Project',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.project == null
                        ? 'Fill in the details below'
                        : 'Modify project information',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Project Information'),
                    const SizedBox(height: 16),

                    // Project Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Project Name',
                      icon: Icons.apartment,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter project name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Project Type
                    DropdownButtonFormField<String>(
                      value: _projectType,
                      decoration: InputDecoration(
                        labelText: 'Project Type',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _projectTypeIcons[_projectType] ?? Icons.category,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      items: _projectTypes
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _projectTypeIcons[type] ?? Icons.category,
                              size: 20,
                              color: const Color(0xFF1A237E),
                            ),
                            const SizedBox(width: 12),
                            Text(type.replaceAll('_', ' ')),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _projectType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Budget
                    _buildTextField(
                      controller: _budgetController,
                      label: 'Budget (\$)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter budget';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Project Manager
                    _isLoadingManagers
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : DropdownButtonFormField<Employee>(
                      value: _selectedProjectManager,
                      decoration: InputDecoration(
                        labelText: 'Project Manager',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      items: _projectManagers
                          .map((manager) => DropdownMenuItem(
                        value: manager,
                        child: Text(manager.name ?? 'N/A'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectManager = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a project manager';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Timeline'),
                    const SizedBox(height: 16),

                    // Start Date
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF1A237E),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _startDate != null
                                        ? DateFormat('MMMM dd, yyyy')
                                        .format(_startDate!)
                                        : 'Select Start Date',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1A237E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expected End Date
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BFA5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Color(0xFF00BFA5),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expected End Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _expectedEndDate != null
                                        ? DateFormat('MMMM dd, yyyy')
                                        .format(_expectedEndDate!)
                                        : 'Select End Date',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF00BFA5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Description'),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Project Description',
                      icon: Icons.description,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: const Color(0xFF00BFA5).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.project == null
                                ? Icons.add
                                : Icons.check),
                            const SizedBox(width: 8),
                            Text(
                              widget.project == null
                                  ? 'Create Project'
                                  : 'Update Project',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A237E),
                Color(0xFF00BFA5),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      validator: validator,
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