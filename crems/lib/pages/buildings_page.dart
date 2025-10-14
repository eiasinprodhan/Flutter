import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/building_service.dart';
import 'building_form_page.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentOrange = Color(0xFFFFB74D);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

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

  final List<String> buildingTypes = ['All', 'RESIDENTIAL', 'COMMERCIAL', 'MIXED_USE', 'INDUSTRIAL'];

  final Map<String, Color> typeColors = {
    'RESIDENTIAL': accentGreen,
    'COMMERCIAL': primaryViolet,
    'MIXED_USE': secondaryViolet,
    'INDUSTRIAL': accentRed,
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
        final matchesType = selectedType == null || selectedType == 'All' || building.type == selectedType;
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
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
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
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: accentRed), SizedBox(width: 12), Text('Confirm Delete')]),
        content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await BuildingService.deleteBuilding(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 12), Text('Building deleted successfully')]), backgroundColor: accentGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))));
          _loadBuildings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Row(children: [Icon(Icons.error_outline, color: Colors.white), SizedBox(width: 12), Text('Failed to delete building')]), backgroundColor: accentRed, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))));
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
        elevation: 2.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buildings'),
            if (!isLoading)
              Text(
                '${filteredBuildings.length} building${filteredBuildings.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
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
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const BuildingFormPage()));
          if (result == true) _loadBuildings();
        },
        backgroundColor: primaryViolet,
        icon: const Icon(Icons.add_business, color: Colors.white),
        label: const Text('New Building', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet))
                : errorMessage != null
                ? _buildErrorState()
                : filteredBuildings.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadBuildings,
              color: primaryViolet,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: filteredBuildings.length,
                itemBuilder: (context, index) => _buildBuildingCard(filteredBuildings[index]),
              ),
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
              hintText: 'Search buildings...',
              prefixIcon: const Icon(Icons.search, color: primaryViolet),
              suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => _searchController.clear()) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: backgroundLight,
            ),
          ),
          const SizedBox(height: 12),
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
                    onSelected: (selected) => _filterByType(type == 'All' ? null : type),
                    backgroundColor: backgroundLight,
                    selectedColor: _getTypeColor(type).withOpacity(0.2),
                    checkmarkColor: _getTypeColor(type),
                    labelStyle: TextStyle(color: isSelected ? _getTypeColor(type) : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    elevation: isSelected ? 2 : 0,
                    shadowColor: _getTypeColor(type).withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? _getTypeColor(type).withOpacity(0.5) : Colors.grey.shade300)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('Oops! Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadBuildings,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.domain_disabled_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No buildings found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Create your first building to get started.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String? type) {
    return typeColors[type] ?? const Color(0xFF757575);
  }

  // --- UPDATED BUILDING CARD WIDGET FOR "FLOATING" EFFECT ---
  Widget _buildBuildingCard(Building building) {
    final imageUrl = building.photo != null && building.photo!.isNotEmpty ? 'http://localhost:8080/images/buildings/${building.photo}' : null;
    final buildingColor = _getTypeColor(building.type);

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
            // Navigate to detail page
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(building.name ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet))),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BuildingFormPage(building: building)));
                              if (result == true) _loadBuildings();
                            } else if (value == 'delete') {
                              _deleteBuilding(building.id!, building.name!);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: primaryViolet), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
                            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: accentRed), title: Text('Delete', style: TextStyle(color: accentRed)), dense: true, contentPadding: EdgeInsets.zero)),
                          ],
                          icon: const Icon(Icons.more_vert, color: primaryViolet),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(child: Text(building.location ?? 'No location', style: TextStyle(fontSize: 13, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                    ]),
                    const Divider(height: 24),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _buildInfoChip(icon: typeIcons[building.type] ?? Icons.business, label: (building.type ?? 'N/A').replaceAll('_', ' '), color: buildingColor),
                        _buildInfoChip(icon: Icons.layers_outlined, label: '${building.floorCount ?? 0} Floors', color: secondaryViolet),
                        _buildInfoChip(icon: Icons.meeting_room_outlined, label: '${building.unitCount ?? 0} Units', color: secondaryViolet),
                        if (building.project != null)
                          _buildInfoChip(icon: Icons.assignment_outlined, label: 'Project: ${building.project!.name ?? 'N/A'}', color: accentOrange),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}