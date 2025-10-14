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

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

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
  int? _selectedSiteManagerId;
  int? _selectedProjectId;

  List<Employee> _siteManagers = [];
  List<Project> _projects = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  XFile? _imageFile;
  Uint8List? _webImage;

  final ImagePicker _picker = ImagePicker();

  final List<String> _buildingTypes = ['RESIDENTIAL', 'COMMERCIAL', 'MIXED_USE'];

  final Map<String, IconData> _buildingTypeIcons = {
    'RESIDENTIAL': Icons.home_work_outlined,
    'COMMERCIAL': Icons.store_mall_directory_outlined,
    'MIXED_USE': Icons.location_city_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _populateForm() {
    final building = widget.building!;
    _nameController.text = building.name ?? '';
    _locationController.text = building.location ?? '';
    _floorCountController.text = building.floorCount?.toString() ?? '';
    _unitCountController.text = building.unitCount?.toString() ?? '';
    _buildingType = building.type ?? 'RESIDENTIAL';
    _selectedSiteManagerId = building.siteManager?.id;
    _selectedProjectId = building.project?.id;
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final managersFuture = EmployeeService.getEmployeesByRole('SITE_MANAGER');
      final projectsFuture = ProjectService.getAllProjects();

      final results = await Future.wait([managersFuture, projectsFuture]);

      if (mounted) {
        setState(() {
          _siteManagers = results[0] as List<Employee>;
          _projects = results[1] as List<Project>;
          _isLoadingData = false;
        });
        if (widget.building != null) _populateForm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        _showErrorSnackBar('Failed to load initial data: $e');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _imageFile = image;
            _webImage = bytes;
          });
        } else {
          setState(() => _imageFile = image);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Choose Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
            const SizedBox(height: 20),
            if (!kIsWeb)
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: secondaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt, color: secondaryViolet)),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library, color: primaryViolet)),
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
    if (_imageFile != null) {
      if (kIsWeb && _webImage != null) return Image.memory(_webImage!, fit: BoxFit.cover);
      else if (!kIsWeb) return Image.file(File(_imageFile!.path), fit: BoxFit.cover);
    }
    if (widget.building?.photo != null && widget.building!.photo!.isNotEmpty) {
      final imageUrl = 'http://localhost:8080/images/buildings/${widget.building!.photo}';
      return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.business_rounded, size: 60, color: Colors.grey[400]));
    }
    return Icon(Icons.business_rounded, size: 60, color: Colors.grey[400]);
  }

  Future<void> _saveBuilding() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final selectedManager = _selectedSiteManagerId == null ? null : _siteManagers.firstWhere((m) => m.id == _selectedSiteManagerId);
        final selectedProject = _selectedProjectId == null ? null : _projects.firstWhere((p) => p.id == _selectedProjectId);
        final building = Building(
          id: widget.building?.id,
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          floorCount: int.tryParse(_floorCountController.text),
          unitCount: int.tryParse(_unitCountController.text),
          type: _buildingType,
          siteManager: selectedManager,
          project: selectedProject,
        );
        bool success;
        if (widget.building == null) {
          success = await BuildingService.createBuilding(building, _imageFile);
        } else {
          success = await BuildingService.updateBuilding(building, _imageFile);
        }
        if (mounted) {
          setState(() => _isLoading = false);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.building == null ? 'Building created successfully' : 'Building updated successfully'),
                backgroundColor: accentGreen,
              ),
            );
            Navigator.pop(context, true);
          } else {
            _showErrorSnackBar('Failed to save building. Please try again.');
          }
        }
      } catch (e) {
        debugPrint('Error saving building: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('An error occurred: $e');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message))]),
      backgroundColor: accentRed,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(widget.building == null ? 'New Building' : 'Edit Building'),
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: primaryViolet))
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primaryViolet, secondaryViolet]),
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildImagePreview()),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [secondaryViolet, primaryViolet]), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tap to upload building image', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
            _buildSectionTitle('Building Information'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nameController, label: 'Building Name', icon: Icons.business_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _buildingType,
              decoration: _inputDecoration('Building Type', _buildingTypeIcons[_buildingType] ?? Icons.business_rounded),
              items: _buildingTypes.map((type) => DropdownMenuItem(value: type, child: Text(type.replaceAll('_', ' ')))).toList(),
              onChanged: (v) => setState(() => _buildingType = v!),
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: _locationController, label: 'Location', icon: Icons.location_on_outlined, maxLines: 2, validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a location' : null),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _floorCountController, label: 'Floors', icon: Icons.layers_outlined, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null ? 'Invalid' : null)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _unitCountController, label: 'Units', icon: Icons.meeting_room_outlined, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null ? 'Invalid' : null)),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Assignment'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedProjectId,
              decoration: _inputDecoration('Project (Optional)', Icons.assignment_outlined),
              items: _projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name ?? 'N/A'))).toList(),
              onChanged: (v) => setState(() => _selectedProjectId = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedSiteManagerId,
              decoration: _inputDecoration('Site Manager (Optional)', Icons.person_outline, color: secondaryViolet),
              items: _siteManagers.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name ?? 'N/A'))).toList(),
              onChanged: (v) => setState(() => _selectedSiteManagerId = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveBuilding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryViolet,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(widget.building == null ? Icons.add_circle_outline : Icons.save_outlined),
                label: Text(widget.building == null ? 'Create Building' : 'Update Building', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  InputDecoration _inputDecoration(String label, IconData icon, {Color? color}) {
    final iconColor = color ?? primaryViolet;
    return InputDecoration(
      labelText: label,
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
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