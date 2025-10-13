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

  Project? _selectedProject;
  Building? _selectedBuilding;
  Floor? _selectedFloor;
  bool _isBooked = false;
  List<XFile> _images = [];

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
      if(mounted) {
        setState(() {
          _projects = projects;
          if (widget.unit != null) {
            _populateForm();
          } else {
            _isLoadingData = false;
          }
        });
      }
    } catch (e) {
      if(mounted) setState(() => _isLoadingData = false);
    }
  }

  void _populateForm() async {
    final unit = widget.unit!;
    _unitNumberController.text = unit.unitNumber ?? '';
    _areaController.text = unit.area?.toString() ?? '';
    _bedroomsController.text = unit.bedrooms?.toString() ?? '';
    _bathroomsController.text = unit.bathrooms?.toString() ?? '';
    _priceController.text = unit.price?.toString() ?? '';
    _interestRateController.text = unit.interestRate?.toString() ?? '';
    _isBooked = unit.isBooked;

    if (unit.building?.project != null) {
      _selectedProject = _projects.firstWhere((p) => p.id == unit.building!.project!.id, orElse: () => _projects.first);
      await _onProjectChanged(_selectedProject, initialLoad: true);
    }
    if (unit.building != null) {
      _selectedBuilding = _buildings.firstWhere((b) => b.id == unit.building!.id, orElse: () => _buildings.first);
      await _onBuildingChanged(_selectedBuilding, initialLoad: true);
    }
    if (unit.floor != null) {
      _selectedFloor = _floors.firstWhere((f) => f.id == unit.floor!.id, orElse: () => _floors.first);
    }
    if(mounted) setState(() {});
  }

  Future<void> _onProjectChanged(Project? project, {bool initialLoad = false}) async {
    setState(() {
      _selectedProject = project;
      if (!initialLoad) {
        _selectedBuilding = null;
        _selectedFloor = null;
      }
      _buildings = [];
      _floors = [];
    });
    if (project != null) {
      final buildings = await BuildingService.getBuildingsByProject(project.id!);
      if(mounted) setState(() => _buildings = buildings);
    }
  }

  Future<void> _onBuildingChanged(Building? building, {bool initialLoad = false}) async {
    setState(() {
      _selectedBuilding = building;
      if (!initialLoad) _selectedFloor = null;
      _floors = [];
    });
    if (building != null) {
      final floors = await FloorService.getFloorsByBuilding(building.id!);
      if(mounted) setState(() => _floors = floors);
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if(mounted) setState(() => _images.addAll(images));
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;
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
      building: _selectedBuilding,
      floor: _selectedFloor,
    );

    bool success;
    if (widget.unit == null) {
      success = await UnitService.createUnit(unit, _images);
    } else {
      success = await UnitService.updateUnit(unit, _images);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Unit saved successfully' : 'Failed to save unit'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.unit == null ? 'New Unit' : 'Edit Unit')),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionTitle('Unit Details'),
            const SizedBox(height: 16),
            _buildTextField(_unitNumberController, 'Unit Number', Icons.tag, validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_areaController, 'Area (sqft)', Icons.square_foot, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_priceController, 'Price (\$)', Icons.attach_money, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(_bedroomsController, 'Bedrooms', Icons.king_bed, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_bathroomsController, 'Bathrooms', Icons.bathtub, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 16),
            _buildTextField(_interestRateController, 'Interest Rate (%)', Icons.percent, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Is Booked'),
              value: _isBooked,
              onChanged: (val) => setState(() => _isBooked = val),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Location'),
            const SizedBox(height: 16),
            _buildDropdown(_projects, _selectedProject, 'Project', (val) => _onProjectChanged(val as Project?), validator: (v) => v == null ? 'Required' : null),
            const SizedBox(height: 16),
            _buildDropdown(_buildings, _selectedBuilding, 'Building', (val) => _onBuildingChanged(val as Building?), validator: (v) => v == null ? 'Required' : null),
            const SizedBox(height: 16),
            _buildDropdown(_floors, _selectedFloor, 'Floor', (val) => setState(() => _selectedFloor = val as Floor?), validator: (v) => v == null ? 'Required' : null),

            const SizedBox(height: 24),
            _buildSectionTitle('Photos (${_images.length})'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Images'),
            ),
            _buildImagePreview(),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveUnit,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Save Unit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_images.isEmpty && (widget.unit?.photoUrls ?? []).isEmpty) return const SizedBox(height: 8);

    List<Widget> imageWidgets = [];

    // Display existing network images
    if (widget.unit?.photoUrls != null) {
      imageWidgets.addAll(widget.unit!.photoUrls!.map((url) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network('http://localhost:8080/images/units/$url', width: 100, height: 100, fit: BoxFit.cover),
        ),
      )));
    }

    // Display newly picked local images
    imageWidgets.addAll(_images.map((imageFile) {
      final index = _images.indexOf(imageFile);
      return Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 100, height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? Image.network(imageFile.path, fit: BoxFit.cover)
                  : Image.file(File(imageFile.path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0, right: 8,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }));

    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: imageWidgets,
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>(List<T> items, T? value, String hint, Function(T?) onChanged, {String? Function(T?)? validator}) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      items: items.map((item) {
        String text = 'N/A';
        if (item is Project) text = item.name ?? 'N/A';
        else if (item is Building) text = item.name ?? 'N/A';
        else if (item is Floor) text = item.name ?? 'N/A';
        return DropdownMenuItem<T>(value: item, child: Text(text));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)));
  }
}