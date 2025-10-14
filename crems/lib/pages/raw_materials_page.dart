// lib/pages/raw_materials_page.dart

import 'package:flutter/material.dart';
import '../models/raw_material.dart';
import '../services/raw_material_service.dart';
import 'raw_material_form_page.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7);
const Color secondaryViolet = Color(0xFF9575CD);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color accentRed = Color(0xFFFF6B6B);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class RawMaterialsPage extends StatefulWidget {
  const RawMaterialsPage({Key? key}) : super(key: key);

  @override
  State<RawMaterialsPage> createState() => _RawMaterialsPageState();
}

class _RawMaterialsPageState extends State<RawMaterialsPage> {
  List<RawMaterial> materials = [];
  List<RawMaterial> filteredMaterials = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMaterials();
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
      filteredMaterials = materials.where((material) {
        final matchesSearch = (material.name?.toLowerCase() ?? '').contains(query) || (material.unit?.toLowerCase() ?? '').contains(query);
        return matchesSearch;
      }).toList();
    });
  }

  Future<void> _loadMaterials() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetchedMaterials = await RawMaterialService.getAllRawMaterials();
      if (mounted) {
        setState(() {
          materials = fetchedMaterials;
          filteredMaterials = fetchedMaterials;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = 'Failed to load materials: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteMaterial(int id, String name) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => _buildDeleteDialog(name));
    if (confirmed == true && mounted) {
      final success = await RawMaterialService.deleteRawMaterial(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Material deleted successfully', Icons.check_circle, accentGreen));
          _loadMaterials();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(_buildStatusSnackBar('Failed to delete material', Icons.error, accentRed));
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
            const Text('Raw Materials'),
            if (!isLoading) Text('${filteredMaterials.length} item${filteredMaterials.length != 1 ? 's' : ''} in stock', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMaterials, tooltip: 'Refresh')],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const RawMaterialFormPage()));
          if (result == true) _loadMaterials();
        },
        backgroundColor: primaryViolet,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Add Material', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet))
                : errorMessage != null
                ? _buildErrorWidget()
                : filteredMaterials.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: filteredMaterials.length,
              itemBuilder: (context, index) => _buildMaterialCard(filteredMaterials[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or unit...',
          prefixIcon: const Icon(Icons.search, color: primaryViolet),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: backgroundLight,
        ),
      ),
    );
  }

  Widget _buildMaterialCard(RawMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15.0, spreadRadius: 2.0, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            // Optional: Navigate to a details page or show a dialog
            Navigator.push(context, MaterialPageRoute(builder: (context) => RawMaterialFormPage(material: material))).then((result) { if (result == true) _loadMaterials(); });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: secondaryViolet.withOpacity(0.1),
                  child: const Icon(Icons.inventory_2_outlined, size: 28, color: secondaryViolet),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(material.name ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet)),
                      const SizedBox(height: 6),
                      Text.rich(
                          TextSpan(
                              children: [
                                TextSpan(text: material.quantity?.toString() ?? '0', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const TextSpan(text: ' ', style: TextStyle(fontSize: 16)),
                                TextSpan(text: material.unit ?? 'units', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              ]
                          )
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RawMaterialFormPage(material: material))).then((result) { if (result == true) _loadMaterials(); });
                    } else if (value == 'delete') {
                      _deleteMaterial(material.id!, material.name!);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, color: primaryViolet), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: accentRed), title: Text('Delete', style: TextStyle(color: accentRed)), dense: true, contentPadding: EdgeInsets.zero)),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AlertDialog _buildDeleteDialog(String name) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.warning_amber_rounded, color: accentRed), SizedBox(width: 12), Text('Confirm Delete')]),
      content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: Colors.white), child: const Text('Delete')),
      ],
    );
  }

  SnackBar _buildStatusSnackBar(String message, IconData icon, Color color) {
    return SnackBar(content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(message)]), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }

  Widget _buildErrorWidget() {
    return Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
      const SizedBox(height: 16),
      Text(errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 16), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: _loadMaterials, icon: const Icon(Icons.refresh), label: const Text('Retry'), style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white)),
    ])));
  }

  Widget _buildEmptyStateWidget() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
      const SizedBox(height: 16),
      Text(materials.isEmpty ? 'No materials in stock' : 'No matching materials found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Text(materials.isEmpty ? 'Add your first raw material to get started' : 'Try adjusting your search filter', style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
    ]));
  }
}