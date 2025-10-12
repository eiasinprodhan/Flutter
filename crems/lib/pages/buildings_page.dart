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

  // Building type options
  final List<String> buildingTypes = [
    'All',
    'RESIDENTIAL',
    'COMMERCIAL',
    'MIXED_USE',
    'INDUSTRIAL',
  ];

  // Type colors
  final Map<String, Color> typeColors = {
    'RESIDENTIAL': const Color(0xFF4CAF50),
    'COMMERCIAL': const Color(0xFF1A237E),
    'MIXED_USE': const Color(0xFF00BFA5),
    'INDUSTRIAL': const Color(0xFFFF6B6B),
  };

  // Type icons
  final Map<String, IconData> typeIcons = {
    'RESIDENTIAL': Icons.home,
    'COMMERCIAL': Icons.business,
    'MIXED_USE': Icons.location_city,
    'INDUSTRIAL': Icons.factory,
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
        // Apply search filter
        final matchesSearch = building.name!.toLowerCase().contains(query) ||
            (building.location ?? '').toLowerCase().contains(query) ||
            (building.siteManager?.name ?? '').toLowerCase().contains(query) ||
            (building.project?.name ?? '').toLowerCase().contains(query);

        // Apply type filter
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
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedBuildings = await BuildingService.getAllBuildings();
      setState(() {
        buildings = fetchedBuildings;
        filteredBuildings = fetchedBuildings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load buildings: $e';
        isLoading = false;
      });
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await BuildingService.deleteBuilding(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Building deleted successfully'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadBuildings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Failed to delete building')),
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

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
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
            MaterialPageRoute(
              builder: (context) => const BuildingFormPage(),
            ),
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
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search buildings by name, location...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          // Type Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list, size: 18, color: Color(0xFF1A237E)),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter by Type:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: buildingTypes.map((type) {
                      final isSelected = selectedType == type ||
                          (selectedType == null && type == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type.replaceAll('_', ' ')),
                          selected: isSelected,
                          onSelected: (selected) {
                            _filterByType(type == 'All' ? null : type);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: _getTypeColor(type).withOpacity(0.2),
                          checkmarkColor: _getTypeColor(type),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? _getTypeColor(type)
                                : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? _getTypeColor(type)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Buildings List
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00BFA5),
              ),
            )
                : errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadBuildings,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : filteredBuildings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    buildings.isEmpty
                        ? 'No buildings found'
                        : 'No matching buildings',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    buildings.isEmpty
                        ? 'Add your first building to get started'
                        : 'Try adjusting your search or filters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (buildings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _filterByType(null);
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredBuildings.length,
              itemBuilder: (context, index) {
                final building = filteredBuildings[index];
                return _buildBuildingCard(building);
              },
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuildingFormPage(building: building),
              ),
            );
            if (result == true) {
              _loadBuildings();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Icon Container
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

                    // Name and Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            building.name ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(building.type ?? '')
                                  .withOpacity(0.1),
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

                    // Action Buttons
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: const Color(0xFF1A237E),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BuildingFormPage(building: building),
                                ),
                              );
                              if (result == true) {
                                _loadBuildings();
                              }
                            },
                            tooltip: 'Edit',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            color: const Color(0xFFFF6B6B),
                            onPressed: () =>
                                _deleteBuilding(building.id!, building.name!),
                            tooltip: 'Delete',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location
                if (building.location != null && building.location!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          building.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.layers,
                        'Floors',
                        '${building.floorCount ?? 0}',
                        const Color(0xFF00BFA5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.meeting_room,
                        'Units',
                        '${building.unitCount ?? 0}',
                        const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Additional Info
                Row(
                  children: [
                    if (building.siteManager != null)
                      Expanded(
                        child: _buildInfoCard(
                          Icons.person_outline,
                          'Site Manager',
                          building.siteManager!.name ?? 'N/A',
                          const Color(0xFFFFB74D),
                        ),
                      ),
                    if (building.siteManager != null && building.project != null)
                      const SizedBox(width: 12),
                    if (building.project != null)
                      Expanded(
                        child: _buildInfoCard(
                          Icons.apartment,
                          'Project',
                          building.project!.name ?? 'N/A',
                          const Color(0xFF4CAF50),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}