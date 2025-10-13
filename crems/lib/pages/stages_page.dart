import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/floor.dart';
import '../models/stage.dart';
import '../services/floor_service.dart';
import '../services/stage_service.dart';
import 'stage_form_page.dart';

class StagesPage extends StatefulWidget {
  const StagesPage({Key? key}) : super(key: key);

  @override
  State<StagesPage> createState() => _StagesPageState();
}

class _StagesPageState extends State<StagesPage> {
  List<Stage> _allStages = [];
  List<Stage> _filteredStages = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  List<Floor> _floorsForFilter = [];
  Floor? _selectedFloor;

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
      final results = await Future.wait([
        StageService.getAllStages(),
        FloorService.getAllFloors(),
      ]);

      if (mounted) {
        setState(() {
          _allStages = results[0] as List<Stage>;
          _filteredStages = _allStages;
          _floorsForFilter = results[1] as List<Floor>;
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
      _filteredStages = _allStages.where((stage) {
        final nameMatches = stage.name?.toLowerCase().contains(query) ?? false;
        final floorMatches =
            _selectedFloor == null || stage.floor?.id == _selectedFloor!.id;
        return nameMatches && floorMatches;
      }).toList();
    });
  }

  void _filterByFloor(Floor? floor) {
    setState(() {
      _selectedFloor = floor;
      _applyFilters();
    });
  }

  Future<void> _deleteStage(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(name),
    );

    if (confirmed == true && mounted) {
      final success = await StageService.deleteStage(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildStatusSnackBar(
                'Stage deleted successfully', Icons.check_circle, Colors.green),
          );
          _loadInitialData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildStatusSnackBar(
                'Failed to delete stage', Icons.error, Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Stages'),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StageFormPage()),
          );
          if (result == true) {
            _loadInitialData();
          }
        },
        backgroundColor: const Color(0xFF00BFA5),
        icon: const Icon(Icons.add),
        label: const Text('New Stage'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorWidget()
                : _filteredStages.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredStages.length,
              itemBuilder: (context, index) {
                return _buildStageCard(_filteredStages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by stage name...',
              prefixIcon: const Icon(Icons.search),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Floor?>(
            value: _selectedFloor,
            decoration: InputDecoration(
              labelText: 'Filter by Floor',
              prefixIcon: const Icon(Icons.layers_outlined),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: [
              const DropdownMenuItem<Floor?>(
                  value: null, child: Text('All Floors')),
              ..._floorsForFilter.map((floor) => DropdownMenuItem(
                value: floor,
                child: Text(
                    '${floor.name ?? 'N/A'} (${floor.building?.name ?? '...'})'),
              )),
            ],
            onChanged: (value) => _filterByFloor(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(Stage stage) {
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
              children: [
                const Icon(Icons.construction,
                    color: Color(0xFF1A237E), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stage.name ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E))),
                      const SizedBox(height: 4),
                      Text(
                        'Floor: ${stage.floor?.name ?? 'N/A'} | Building: ${stage.floor?.building?.name ?? 'N/A'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  StageFormPage(stage: stage)))
                          .then((result) {
                        if (result == true) _loadInitialData();
                      });
                    } else if (value == 'delete') {
                      _deleteStage(stage.id!, stage.name!);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child:
                        Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                    Icons.calendar_today,
                    'Start: ${stage.startDate != null ? DateFormat.yMMMd().format(stage.startDate!) : 'N/A'}'),
                _buildInfoChip(Icons.event,
                    'End: ${stage.endDate != null ? DateFormat.yMMMd().format(stage.endDate!) : 'N/A'}'),
                _buildInfoChip(
                    Icons.groups, '${stage.labours?.length ?? 0} Labours',
                    color: const Color(0xFF00BFA5)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
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
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(
      content:
      Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]),
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
            Text(_errorMessage!,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E)),
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
            _allStages.isEmpty ? 'No stages found' : 'No matching stages',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _allStages.isEmpty
                ? 'Add your first stage to get started'
                : 'Try adjusting your search or filter',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (_allStages.isNotEmpty &&
              (_searchController.text.isNotEmpty || _selectedFloor != null)) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _filterByFloor(null);
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E)),
            ),
          ],
        ],
      ),
    );
  }
}