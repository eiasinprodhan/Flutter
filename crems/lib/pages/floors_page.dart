import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/building.dart';
import '../models/floor.dart';
import '../services/building_service.dart';
import '../services/floor_service.dart';
import 'floor_form_page.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentOrange = Color(0xFFFFB74D);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class FloorsPage extends StatefulWidget {
  const FloorsPage({Key? key}) : super(key: key);

  @override
  State<FloorsPage> createState() => _FloorsPageState();
}

class _FloorsPageState extends State<FloorsPage> {
  List<Floor> _allFloors = [];
  List<Floor> _filteredFloors = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  List<Building> _buildingsForFilter = [];
  Building? _selectedBuilding;

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([FloorService.getAllFloors(), BuildingService.getAllBuildings()]);
      if (mounted) {
        setState(() {
          _allFloors = results[0] as List<Floor>;
          _filteredFloors = _allFloors;
          _buildingsForFilter = results[1] as List<Building>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFloors = _allFloors.where((floor) {
        final nameMatches = floor.name?.toLowerCase().contains(query) ?? false;
        final buildingNameMatches = floor.building?.name?.toLowerCase().contains(query) ?? false;
        final buildingMatches = _selectedBuilding == null || floor.building?.id == _selectedBuilding!.id;
        return (nameMatches || buildingNameMatches) && buildingMatches;
      }).toList();
    });
  }

  void _filterByBuilding(Building? building) {
    setState(() {
      _selectedBuilding = building;
      _applyFilters();
    });
  }

  Future<void> _deleteFloor(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(name),
    );

    if (confirmed == true && mounted) {
      final success = await FloorService.deleteFloor(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Floor deleted successfully', Icons.check_circle, accentGreen));
          _loadInitialData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Failed to delete floor', Icons.error, accentRed));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Floors'),
            if (!_isLoading)
              Text(
                '${_filteredFloors.length} floor${_filteredFloors.length != 1 ? 's' : ''} found',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const FloorFormPage()));
          if (result == true) _loadInitialData();
        },
        backgroundColor: primaryViolet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Floor', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet))
                : _errorMessage != null
                ? _buildErrorWidget()
                : _filteredFloors.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _filteredFloors.length,
              itemBuilder: (context, index) => _buildFloorCard(_filteredFloors[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by floor or building name...',
              prefixIcon: const Icon(Icons.search, color: primaryViolet),
              suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: backgroundLight,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Building?>(
            value: _selectedBuilding,
            decoration: InputDecoration(
              labelText: 'Filter by Building',
              prefixIcon: const Icon(Icons.business_rounded, color: secondaryViolet),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: backgroundLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            items: [
              const DropdownMenuItem<Building?>(value: null, child: Text('All Buildings')),
              ..._buildingsForFilter.map((building) => DropdownMenuItem(value: building, child: Text(building.name ?? 'Unnamed Building'))),
            ],
            onChanged: (value) => _filterByBuilding(value),
          ),
        ],
      ),
    );
  }

  // --- UPDATED FLOOR CARD WIDGET FOR "FLOATING" EFFECT ---
  Widget _buildFloorCard(Floor floor) {
    final daysRemaining = floor.expectedEndDate?.difference(DateTime.now()).inDays ?? 0;
    final isOverdue = daysRemaining < 0 && floor.expectedEndDate != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20.0,
            spreadRadius: 4.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            // Future navigation to detail page
            print('Tapped on floor: ${floor.name}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.layers_outlined, color: primaryViolet, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(floor.name ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
                          const SizedBox(height: 4),
                          if (floor.building != null) Text('Building: ${floor.building!.name}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FloorFormPage(floor: floor))).then((result) {
                            if (result == true) _loadInitialData();
                          });
                        } else if (value == 'delete') {
                          _deleteFloor(floor.id!, floor.name!);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: primaryViolet), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
                        const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: accentRed), title: Text('Delete', style: TextStyle(color: accentRed)), dense: true, contentPadding: EdgeInsets.zero)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildInfoChip(Icons.business_outlined, floor.building?.type?.replaceAll('_', ' ') ?? 'N/A', color: secondaryViolet),
                    if (floor.expectedEndDate != null)
                      _buildInfoChip(
                        isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_outlined,
                        isOverdue ? 'Overdue by ${daysRemaining.abs()} days' : '$daysRemaining days remaining',
                        color: isOverdue ? accentRed : accentGreen,
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    final chipColor = color ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: chipColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: chipColor)),
        ],
      ),
    );
  }

  Widget _buildDeleteDialog(String name) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.warning_amber_rounded, color: accentRed), SizedBox(width: 12), Text('Confirm Delete')]),
      content: Text('Are you sure you want to delete "$name"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: Colors.white),
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
              style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white),
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
          Icon(Icons.layers_clear_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _allFloors.isEmpty ? 'No floors found' : 'No matching floors',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _allFloors.isEmpty ? 'Add your first floor to get started' : 'Try adjusting your search or filter',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (_allFloors.isNotEmpty && (_searchController.text.isNotEmpty || _selectedBuilding != null)) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _filterByBuilding(null);
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}