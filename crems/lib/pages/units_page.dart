import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/building.dart';
import '../models/floor.dart';
import '../models/project.dart';
import '../models/unit.dart';
import '../services/building_service.dart';
import '../services/floor_service.dart';
import '../services/project_service.dart';
import '../services/unit_service.dart';
import 'unit_form_page.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({Key? key}) : super(key: key);

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  List<Unit> _allUnits = [];
  List<Unit> _filteredUnits = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  Project? _selectedProject;
  Building? _selectedBuilding;
  Floor? _selectedFloor;

  List<Project> _projectsForFilter = [];
  List<Building> _buildingsForFilter = [];
  List<Floor> _floorsForFilter = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        UnitService.getAllUnits(),
        ProjectService.getAllProjects(),
      ]);
      if (mounted) {
        setState(() {
          _allUnits = results[0] as List<Unit>;
          _filteredUnits = _allUnits;
          _projectsForFilter = results[1] as List<Project>;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to load data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUnits = _allUnits.where((unit) {
        final searchMatch = unit.unitNumber?.toLowerCase().contains(query) ?? false;
        final projectMatch = _selectedProject == null || unit.building?.project?.id == _selectedProject!.id;
        final buildingMatch = _selectedBuilding == null || unit.building?.id == _selectedBuilding!.id;
        final floorMatch = _selectedFloor == null || unit.floor?.id == _selectedFloor!.id;
        return searchMatch && projectMatch && buildingMatch && floorMatch;
      }).toList();
    });
  }

  Future<void> _onProjectChanged(Project? project) async {
    setState(() {
      _selectedProject = project;
      _selectedBuilding = null;
      _selectedFloor = null;
      _buildingsForFilter = [];
      _floorsForFilter = [];
    });
    if (project != null) {
      try {
        final buildings = await BuildingService.getBuildingsByProject(project.id!);
        if(mounted) setState(() => _buildingsForFilter = buildings);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load buildings: $e'), backgroundColor: Colors.red));
        }
      }
    }
    _applyFilters();
  }

  Future<void> _onBuildingChanged(Building? building) async {
    setState(() {
      _selectedBuilding = building;
      _selectedFloor = null;
      _floorsForFilter = [];
    });
    if (building != null) {
      try {
        final floors = await FloorService.getFloorsByBuilding(building.id!);
        if (mounted) setState(() => _floorsForFilter = floors);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load floors: $e'), backgroundColor: Colors.red));
        }
      }
    }
    _applyFilters();
  }

  void _onFloorChanged(Floor? floor) {
    setState(() => _selectedFloor = floor);
    _applyFilters();
  }

  Future<void> _deleteUnit(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(name),
    );

    if (confirmed == true && mounted) {
      final success = await UnitService.deleteUnit(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildStatusSnackBar(
            success ? 'Unit deleted successfully' : 'Failed to delete unit',
            success ? Icons.check_circle : Icons.error,
            success ? Colors.green : Colors.red,
          ),
        );
        if (success) _loadInitialData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Units / Apartments'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitFormPage()));
          if (result == true) _loadInitialData();
        },
        label: const Text('New Unit'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorWidget()
                : _filteredUnits.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredUnits.length,
              itemBuilder: (context, index) {
                return _buildUnitCard(_filteredUnits[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(controller: _searchController, decoration: InputDecoration(hintText: 'Search Unit Number...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdown(_projectsForFilter, _selectedProject, 'Project', (val) => _onProjectChanged(val as Project?), Icons.apartment)),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown(_buildingsForFilter, _selectedBuilding, 'Building', (val) => _onBuildingChanged(val as Building?), Icons.business, isEnabled: _selectedProject != null)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdown(_floorsForFilter, _selectedFloor, 'Floor', (val) => _onFloorChanged(val as Floor?), Icons.layers, isEnabled: _selectedBuilding != null),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(List<T> items, T? value, String hint, Function(T?) onChanged, IconData icon, {bool isEnabled = true}) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !isEnabled,
        fillColor: Colors.grey[200],
      ),
      items: items.map((item) {
        String text = 'N/A';
        if (item is Project) text = item.name ?? 'N/A';
        else if (item is Building) text = item.name ?? 'N/A';
        else if (item is Floor) text = item.name ?? 'N/A';
        return DropdownMenuItem<T>(value: item, child: Text(text, overflow: TextOverflow.ellipsis));
      }).toList(),
      onChanged: isEnabled ? onChanged : null,
      isExpanded: true,
    );
  }

  Widget _buildUnitCard(Unit unit) {
    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.meeting_room_outlined, color: Theme.of(context).primaryColor, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unit #${unit.unitNumber}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${unit.building?.name ?? '...'} / Floor ${unit.floor?.name ?? '...'}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: unit.isBooked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    unit.isBooked ? 'BOOKED' : 'AVAILABLE',
                    style: TextStyle(color: unit.isBooked ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UnitFormPage(unit: unit)))
                          .then((result) { if (result == true) _loadInitialData(); });
                    } else if (value == 'delete') {
                      _deleteUnit(unit.id!, unit.unitNumber!);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                  ],
                ),
              ],
            ),
            if (unit.photoUrls != null && unit.photoUrls!.isNotEmpty) ...[
              const Divider(height: 24),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: unit.photoUrls!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'http://localhost:8080/images/units/${unit.photoUrls![index]}',
                          width: 80, height: 80, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.hide_image_outlined)),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(Icons.square_foot_outlined, '${unit.area ?? 0} sqft'),
                _buildInfoChip(Icons.king_bed_outlined, '${unit.bedrooms ?? 0} Beds'),
                _buildInfoChip(Icons.bathtub_outlined, '${unit.bathrooms ?? 0} Baths'),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                formatCurrency.format(unit.price ?? 0),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[800])),
      ],
    );
  }

  AlertDialog _buildDeleteDialog(String name) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
          SizedBox(width: 12),
          Text('Confirm Delete'),
        ],
      ),
      content: Text('Are you sure you want to delete Unit #$name?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(
      content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _allUnits.isEmpty ? 'No units found' : 'No matching units',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _allUnits.isEmpty ? 'Add your first unit to get started' : 'Try adjusting your search or filter',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}