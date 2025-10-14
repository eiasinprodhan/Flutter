import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/building.dart';
import '../models/floor.dart';
import '../models/project.dart';
import '../models/unit.dart';
import '../services/building_service.dart';
import '../services/floor_service.dart';
import '../services/project_service.dart';
import '../services/unit_service.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class UnitFormPage extends StatefulWidget {
  final Unit? unit;
  const UnitFormPage({Key? key, this.unit}) : super(key: key);

  @override
  State<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _unitNumberController = TextEditingController();
  final _areaController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _priceController = TextEditingController();
  final _interestRateController = TextEditingController();

  int? _selectedProjectId;
  int? _selectedBuildingId;
  int? _selectedFloorId;

  bool _isBooked = false;
  List<XFile> _newImages = [];

  List<Project> _projects = [];
  List<Building> _buildings = [];
  List<Floor> _floors = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    try {
      final projects = await ProjectService.getAllProjects();
      if (mounted) {
        setState(() => _projects = projects);
        if (widget.unit != null) await _populateForm();
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Failed to load project data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _populateForm() async {
    final unit = widget.unit!;
    _unitNumberController.text = unit.unitNumber ?? '';
    _areaController.text = unit.area?.toString() ?? '';
    _bedroomsController.text = unit.bedrooms?.toString() ?? '';
    _bathroomsController.text = unit.bathrooms?.toString() ?? '';
    _priceController.text = unit.price?.toString() ?? '';
    _interestRateController.text = unit.interestRate?.toString() ?? '';
    _isBooked = unit.isBooked;

    if (unit.building?.project?.id != null) {
      _selectedProjectId = unit.building!.project!.id;
      await _onProjectChanged(_selectedProjectId);
    }
    if (unit.building?.id != null) {
      _selectedBuildingId = unit.building!.id;
      await _onBuildingChanged(_selectedBuildingId);
    }
    if (unit.floor?.id != null) {
      _selectedFloorId = unit.floor!.id;
    }
  }

  Future<void> _onProjectChanged(int? projectId) async {
    setState(() {
      _selectedProjectId = projectId;
      _selectedBuildingId = null;
      _selectedFloorId = null;
      _buildings = [];
      _floors = [];
    });
    if (projectId != null) {
      final buildings = await BuildingService.getBuildingsByProject(projectId);
      if (mounted) setState(() => _buildings = buildings);
    }
  }

  Future<void> _onBuildingChanged(int? buildingId) async {
    setState(() {
      _selectedBuildingId = buildingId;
      _selectedFloorId = null;
      _floors = [];
    });
    if (buildingId != null) {
      final floors = await FloorService.getFloorsByBuilding(buildingId);
      if (mounted) setState(() => _floors = floors);
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (mounted) setState(() => _newImages.addAll(images));
  }

  void _removeImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBuildingId == null || _selectedFloorId == null) {
      _showErrorSnackBar('Please select a building and floor.');
      return;
    }
    setState(() => _isLoading = true);

    final unit = Unit(
      id: widget.unit?.id,
      unitNumber: _unitNumberController.text,
      area: double.tryParse(_areaController.text),
      bedrooms: int.tryParse(_bedroomsController.text),
      bathrooms: int.tryParse(_bathroomsController.text),
      price: double.tryParse(_priceController.text),
      interestRate: double.tryParse(_interestRateController.text),
      isBooked: _isBooked,
      building: Building(id: _selectedBuildingId),
      floor: Floor(id: _selectedFloorId),
      photoUrls: widget.unit?.photoUrls,
    );

    bool success;
    if (widget.unit == null) {
      success = await UnitService.createUnit(unit, _newImages);
    } else {
      success = await UnitService.updateUnit(unit, _newImages);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Unit saved successfully' : 'Failed to save unit'), backgroundColor: success ? accentGreen : accentRed));
      if (success) Navigator.pop(context, true);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: accentRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(title: Text(widget.unit == null ? 'New Unit' : 'Edit Unit'), backgroundColor: primaryViolet, foregroundColor: Colors.white),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: primaryViolet))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionTitle('Unit Details'),
            const SizedBox(height: 16),
            _buildTextField(_unitNumberController, 'Unit Number', Icons.tag_outlined, validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_areaController, 'Area (sqft)', Icons.square_foot_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_priceController, 'Price (\$)', Icons.attach_money_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_bedroomsController, 'Bedrooms', Icons.king_bed_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_bathroomsController, 'Bathrooms', Icons.bathtub_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 16),
            _buildTextField(_interestRateController, 'Interest Rate (%)', Icons.percent_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Is Booked'),
              value: _isBooked,
              onChanged: (val) => setState(() => _isBooked = val),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.white,
              activeColor: primaryViolet,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Location'),
            const SizedBox(height: 16),
            _buildDropdown<Project>(_projects, _selectedProjectId, 'Project', (val) => _onProjectChanged(val as int?), icon: Icons.apartment_outlined, validator: (v) => v == null ? 'Required' : null),
            const SizedBox(height: 16),
            _buildDropdown<Building>(_buildings, _selectedBuildingId, 'Building', (val) => _onBuildingChanged(val as int?), icon: Icons.business_rounded, validator: (v) => v == null ? 'Required' : null),
            const SizedBox(height: 16),
            _buildDropdown<Floor>(_floors, _selectedFloorId, 'Floor', (val) => setState(() => _selectedFloorId = val as int?), icon: Icons.layers_outlined, validator: (v) => v == null ? 'Required' : null),
            const SizedBox(height: 24),
            _buildSectionTitle('Photos (${_newImages.length} new)'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add Images'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryViolet,
                side: const BorderSide(color: primaryViolet),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            _buildImagePreview(),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveUnit,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save_outlined),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Save Unit'),
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
    );
  }

  Widget _buildImagePreview() {
    final existingPhotoCount = widget.unit?.photoUrls?.length ?? 0;
    if (_newImages.isEmpty && existingPhotoCount == 0) return const SizedBox.shrink();

    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: existingPhotoCount + _newImages.length,
        itemBuilder: (context, index) {
          if (index < existingPhotoCount) {
            final url = widget.unit!.photoUrls![index];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('http://localhost:8080/images/units/$url', width: 100, height: 100, fit: BoxFit.cover)),
            );
          }
          final newImageIndex = index - existingPhotoCount;
          final imageFile = _newImages[newImageIndex];
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 100, height: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: kIsWeb ? Image.network(imageFile.path, fit: BoxFit.cover) : Image.file(File(imageFile.path), fit: BoxFit.cover)),
              ),
              Positioned(
                top: 0, right: 8,
                child: GestureDetector(
                  onTap: () => _removeImage(newImageIndex),
                  child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      decoration: _inputDecoration(label, icon),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>(List<dynamic> items, int? value, String hint, Function(int?) onChanged, {IconData? icon, String? Function(int?)? validator}) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: _inputDecoration(hint, icon ?? Icons.arrow_drop_down),
      items: items.map((item) => DropdownMenuItem<int>(value: item.id, child: Text(item.name ?? 'N/A'))).toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryViolet),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryViolet, width: 2.0)),
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