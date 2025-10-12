import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/building.dart';
import '../models/employee.dart';
import '../models/project.dart';
import '../services/building_service.dart';
import '../services/employee_service.dart';
import '../services/project_service.dart';

class BuildingFormPage extends StatefulWidget {
  final Building? building;

  const BuildingFormPage({Key? key, this.building}) : super(key: key);

  @override
  State<BuildingFormPage> createState() => _BuildingFormPageState();
}

class _BuildingFormPageState extends State<BuildingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _floorCountController = TextEditingController();
  final _unitCountController = TextEditingController();

  String _buildingType = 'RESIDENTIAL';
  Employee? _selectedSiteManager;
  Project? _selectedProject;
  List<Employee> _siteManagers = [];
  List<Project> _projects = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  XFile? _imageFile;  // Changed from File to XFile
  Uint8List? _webImage;  // For web image preview

  final ImagePicker _picker = ImagePicker();

  final List<String> _buildingTypes = [
    'RESIDENTIAL',
    'COMMERCIAL',
    'MIXED_USE',
    'INDUSTRIAL',
  ];

  final Map<String, IconData> _buildingTypeIcons = {
    'RESIDENTIAL': Icons.home,
    'COMMERCIAL': Icons.business,
    'MIXED_USE': Icons.location_city,
    'INDUSTRIAL': Icons.factory,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.building != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final building = widget.building!;
    _nameController.text = building.name ?? '';
    _locationController.text = building.location ?? '';
    _floorCountController.text = building.floorCount?.toString() ?? '';
    _unitCountController.text = building.unitCount?.toString() ?? '';
    _buildingType = building.type ?? 'RESIDENTIAL';
    _selectedSiteManager = building.siteManager;
    _selectedProject = building.project;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final managers = await EmployeeService.getEmployeesByRole('SITE_MANAGER');
      final projects = await ProjectService.getAllProjects();
      setState(() {
        _siteManagers = managers;
        _projects = projects;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web, read bytes for preview
          final bytes = await image.readAsBytes();
          setState(() {
            _imageFile = image;
            _webImage = bytes;
          });
        } else {
          // For mobile, just store the file
          setState(() {
            _imageFile = image;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 20),
            if (!kIsWeb)  // Camera option only for mobile
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF00BFA5),
                  ),
                ),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1A237E),
                ),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    // Show selected image
    if (_imageFile != null) {
      if (kIsWeb && _webImage != null) {
        return Image.memory(
          _webImage!,
          fit: BoxFit.cover,
        );
      } else if (!kIsWeb) {
        return Image.file(
          File(_imageFile!.path),
          fit: BoxFit.cover,
        );
      }
    }

    // Show existing building photo
    if (widget.building?.photo != null) {
      return Image.network(
        'http://localhost:8080/images/buildings/${widget.building!.photo}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.business, size: 60, color: Colors.grey[400]);
        },
      );
    }

    // Show placeholder
    return Icon(Icons.business, size: 60, color: Colors.grey[400]);
  }

  Future<void> _saveBuilding() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final building = Building(
          id: widget.building?.id,
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          floorCount: int.tryParse(_floorCountController.text),
          unitCount: int.tryParse(_unitCountController.text),
          type: _buildingType,
          siteManager: _selectedSiteManager,
          project: _selectedProject,
        );

        print('Saving building: ${building.toJson()}');

        bool success;
        if (widget.building == null) {
          success = await BuildingService.createBuilding(building, _imageFile);
        } else {
          success = await BuildingService.updateBuilding(building, _imageFile);
        }

        setState(() {
          _isLoading = false;
        });

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(widget.building == null
                        ? 'Building created successfully'
                        : 'Building updated successfully'),
                  ],
                ),
                backgroundColor: const Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text('Failed to save building. Please try again.')),
                  ],
                ),
                backgroundColor: const Color(0xFFFF6B6B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error saving building: $e');
        if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.building == null ? 'New Building' : 'Edit Building'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildImagePreview(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00BFA5),
                                  const Color(0xFF1A237E),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00BFA5)
                                      .withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to upload building image',
                    style: TextStyle(
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
                    _buildSectionTitle('Building Information'),
                    const SizedBox(height: 16),

                    // Building Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Building Name',
                      icon: Icons.business,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter building name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Building Type
                    DropdownButtonFormField<String>(
                      value: _buildingType,
                      decoration: InputDecoration(
                        labelText: 'Building Type',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _buildingTypeIcons[_buildingType] ?? Icons.business,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      items: _buildingTypes
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _buildingTypeIcons[type] ?? Icons.business,
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
                          _buildingType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Floor Count and Unit Count
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _floorCountController,
                            label: 'Floor Count',
                            icon: Icons.layers,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _unitCountController,
                            label: 'Unit Count',
                            icon: Icons.meeting_room,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Assignment'),
                    const SizedBox(height: 16),

                    // Project
                    DropdownButtonFormField<Project>(
                      value: _selectedProject,
                      decoration: InputDecoration(
                        labelText: 'Project (Optional)',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.apartment,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      items: _projects
                          .map((project) => DropdownMenuItem(
                        value: project,
                        child: Text(project.name ?? 'N/A'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProject = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Site Manager
                    DropdownButtonFormField<Employee>(
                      value: _selectedSiteManager,
                      decoration: InputDecoration(
                        labelText: 'Site Manager (Optional)',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFA5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF00BFA5),
                          ),
                        ),
                      ),
                      items: _siteManagers
                          .map((manager) => DropdownMenuItem(
                        value: manager,
                        child: Text(manager.name ?? 'N/A'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSiteManager = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveBuilding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          disabledBackgroundColor: Colors.grey[400],
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
                            Icon(widget.building == null
                                ? Icons.add
                                : Icons.check),
                            const SizedBox(width: 8),
                            Text(
                              widget.building == null
                                  ? 'Create Building'
                                  : 'Update Building',
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
    _locationController.dispose();
    _floorCountController.dispose();
    _unitCountController.dispose();
    super.dispose();
  }
}