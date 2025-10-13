import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/building_service.dart';
import 'building_form_page.dart';

class BuildingsPage extends StatefulWidget {
  const BuildingsPage({Key? key}) : super(key: key);

  @override
  State<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage> {
  List<Building> buildings = [];
  List<Building> filteredBuildings = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String? selectedType;

  final List<String> buildingTypes = [
    'All', 'RESIDENTIAL', 'COMMERCIAL', 'MIXED_USE', 'INDUSTRIAL',
  ];

  final Map<String, Color> typeColors = {
    'RESIDENTIAL': const Color(0xFF4CAF50),
    'COMMERCIAL': const Color(0xFF1A237E),
    'MIXED_USE': const Color(0xFF00BFA5),
    'INDUSTRIAL': const Color(0xFFFF6B6B),
  };

  final Map<String, IconData> typeIcons = {
    'RESIDENTIAL': Icons.home_rounded,
    'COMMERCIAL': Icons.business_rounded,
    'MIXED_USE': Icons.location_city_rounded,
    'INDUSTRIAL': Icons.factory_rounded,
  };

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBuildings = buildings.where((building) {
        final matchesSearch = (building.name?.toLowerCase() ?? '').contains(query) ||
            (building.location?.toLowerCase() ?? '').contains(query) ||
            (building.siteManager?.name?.toLowerCase() ?? '').contains(query) ||
            (building.project?.name?.toLowerCase() ?? '').contains(query);

        final matchesType = selectedType == null ||
            selectedType == 'All' ||
            building.type == selectedType;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _filterByType(String? type) {
    setState(() {
      selectedType = type;
      _applyFilters();
    });
  }

  Future<void> _loadBuildings() async {
    if(!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetchedBuildings = await BuildingService.getAllBuildings();
      if (mounted) {
        setState(() {
          buildings = fetchedBuildings;
          filteredBuildings = fetchedBuildings;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load buildings: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteBuilding(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 12),
            Text('Confirm Delete'),
          ],
        ),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await BuildingService.deleteBuilding(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Building deleted successfully'), backgroundColor: Colors.green),
          );
          _loadBuildings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete building'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://localhost:8080/images/buildings/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buildings'),
            if (!isLoading)
              Text(
                '${filteredBuildings.length} building${filteredBuildings.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBuildings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuildingFormPage()),
          );
          if (result == true) {
            _loadBuildings();
          }
        },
        backgroundColor: const Color(0xFF00BFA5),
        icon: const Icon(Icons.add_business),
        label: const Text('New Building'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : filteredBuildings.isEmpty
                ? const Center(child: Text('No buildings found.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredBuildings.length,
              itemBuilder: (context, index) {
                return _buildBuildingCard(filteredBuildings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search buildings by name, location...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: buildingTypes.map((type) {
                final isSelected = selectedType == type || (selectedType == null && type == 'All');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type.replaceAll('_', ' ')),
                    selected: isSelected,
                    onSelected: (selected) {
                      _filterByType(type == 'All' ? null : type);
                    },
                    selectedColor: _getTypeColor(type).withOpacity(0.2),
                    checkmarkColor: _getTypeColor(type),
                    labelStyle: TextStyle(
                      color: isSelected ? _getTypeColor(type) : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    return typeColors[type] ?? const Color(0xFF757575);
  }

  Widget _buildBuildingCard(Building building) {
    final imageUrl = _getImageUrl(building.photo);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTypeColor(building.type ?? '').withOpacity(0.8),
                        _getTypeColor(building.type ?? ''),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeIcons[building.type] ?? Icons.business,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name ?? 'N/A',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTypeColor(building.type ?? '').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (building.type ?? 'N/A').replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getTypeColor(building.type ?? ''),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // **FIX: Replaced column of buttons with a PopupMenuButton**
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuildingFormPage(building: building)),
                      ).then((result) {
                        if (result == true) {
                          _loadBuildings();
                        }
                      });
                    } else if (value == 'delete') {
                      _deleteBuilding(building.id!, building.name!);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit')),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red))),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const Divider(height: 24),
            if (building.location != null && building.location!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      building.location!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(child: _buildInfoCard(Icons.layers, 'Floors', '${building.floorCount ?? 0}', const Color(0xFF00BFA5))),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoCard(Icons.meeting_room, 'Units', '${building.unitCount ?? 0}', const Color(0xFF1A237E))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (building.siteManager != null)
                  Expanded(
                    child: _buildInfoCard(Icons.person_outline, 'Site Manager', building.siteManager!.name ?? 'N/A', const Color(0xFFFFB74D)),
                  ),
                if (building.siteManager != null && building.project != null)
                  const SizedBox(width: 12),
                if (building.project != null)
                  Expanded(
                    child: _buildInfoCard(Icons.apartment, 'Project', building.project!.name ?? 'N/A', const Color(0xFF4CAF50)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}