import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'project_form_page.dart';

// --- VIOLET COLOR PALETTE (Consistent with other pages) ---
const Color primaryViolet = Color(0xFF673AB7); // DeepPurple 500
const Color secondaryViolet = Color(0xFF9575CD); // DeepPurple 300
const Color backgroundLight = Color(0xFFF5F5F5); // Grey 100
const Color accentRed = Color(0xFFFF6B6B);
const Color accentOrange = Color(0xFFFFB74D);
const Color accentGreen = Color(0xFF4CAF50);
// --- END OF PALETTE ---

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Project> projects = [];
  List<Project> filteredProjects = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String? selectedProjectType;

  final List<String> projectTypes = [
    'All',
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'INFRASTRUCTURE',
    'MIXED_USE',
  ];

  final Map<String, Color> projectTypeColors = {
    'RESIDENTIAL': accentGreen,
    'COMMERCIAL': primaryViolet,
    'INDUSTRIAL': accentRed,
    'INFRASTRUCTURE': secondaryViolet,
    'MIXED_USE': accentOrange,
  };

  @override
  void initState() {
    super.initState();
    _loadProjects();
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
      filteredProjects = projects.where((project) {
        final matchesSearch = (project.name?.toLowerCase() ?? '').contains(query) ||
            (project.description ?? '').toLowerCase().contains(query) ||
            (project.projectManager?.name ?? '').toLowerCase().contains(query);

        final matchesType = selectedProjectType == null ||
            selectedProjectType == 'All' ||
            project.projectType == selectedProjectType;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _filterByProjectType(String? type) {
    setState(() {
      selectedProjectType = type;
      _applyFilters();
    });
  }

  Future<void> _loadProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedProjects = await ProjectService.getAllProjects();
      if (mounted) {
        setState(() {
          projects = fetchedProjects;
          filteredProjects = fetchedProjects;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load projects: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProject(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: accentRed),
            SizedBox(width: 12),
            Text('Confirm Delete'),
          ],
        ),
        content: Text('Are you sure you want to delete "$name"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: primaryViolet)),
      );

      final success = await ProjectService.deleteProject(id);

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 12), Text('Project deleted successfully')]),
              backgroundColor: accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          );
          _loadProjects();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [Icon(Icons.error_outline, color: Colors.white), SizedBox(width: 12), Text('Failed to delete project')]),
              backgroundColor: accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          );
        }
      }
    }
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return 'N/A';
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  int _getDaysRemaining(DateTime? endDate) {
    if (endDate == null) return 0;
    return endDate.difference(DateTime.now()).inDays;
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
            const Text('Projects'),
            if (!isLoading)
              Text(
                '${filteredProjects.length} project${filteredProjects.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectFormPage()));
          if (result == true) _loadProjects();
        },
        backgroundColor: primaryViolet,
        icon: const Icon(Icons.add_business, color: Colors.white),
        label: const Text('New Project', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryViolet))
                : errorMessage != null
                ? _buildErrorState()
                : filteredProjects.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadProjects,
              color: primaryViolet,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) => _buildProjectCard(filteredProjects[index]),
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
              hintText: 'Search projects by name, manager...',
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
              children: projectTypes.map((type) {
                final isSelected = selectedProjectType == type || (selectedProjectType == null && type == 'All');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type.replaceAll('_', ' ')),
                    selected: isSelected,
                    onSelected: (selected) => _filterByProjectType(type == 'All' ? null : type),
                    backgroundColor: backgroundLight,
                    selectedColor: _getProjectTypeColor(type).withOpacity(0.2),
                    checkmarkColor: _getProjectTypeColor(type),
                    labelStyle: TextStyle(color: isSelected ? _getProjectTypeColor(type) : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    elevation: isSelected ? 2 : 0,
                    shadowColor: _getProjectTypeColor(type).withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? _getProjectTypeColor(type).withOpacity(0.5) : Colors.grey.shade300)),
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
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Oops! Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 8),
            Text(errorMessage!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryViolet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No projects found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || selectedProjectType != null ? 'Try adjusting your filters' : 'Create your first project to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getProjectTypeColor(String type) => projectTypeColors[type] ?? const Color(0xFF757575);

  // --- UPDATED PROJECT CARD WIDGET FOR "FLOATING" EFFECT ---
  Widget _buildProjectCard(Project project) {
    final projectColor = _getProjectTypeColor(project.projectType ?? '');

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
          onTap: () => _showProjectDetails(project),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [projectColor.withOpacity(0.8), projectColor]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: projectColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.apartment, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryViolet), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: projectColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text((project.projectType ?? 'N/A').replaceAll('_', ' '), style: TextStyle(fontSize: 11, color: projectColor, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectFormPage(project: project)));
                        if (result == true) _loadProjects();
                      } else if (value == 'delete') {
                        _deleteProject(project.id!, project.name ?? 'this project');
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'edit', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.edit_outlined, color: primaryViolet), title: Text('Edit'), dense: true)),
                      const PopupMenuItem<String>(value: 'delete', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.delete_outline, color: accentRed), title: Text('Delete', style: TextStyle(color: accentRed)), dense: true)),
                    ],
                    icon: const Icon(Icons.more_vert, color: primaryViolet),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    offset: const Offset(0, 40),
                  ),
                ]),
                const Divider(height: 24, thickness: 1),
                if (project.description != null && project.description!.isNotEmpty) ...[
                  Text(project.description!, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                ],
                Row(children: [
                  Expanded(child: _buildInfoCard(Icons.attach_money, 'Budget', _formatCurrency(project.budget), accentGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard(Icons.person_outline, 'Manager', project.projectManager?.name ?? 'N/A', primaryViolet)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildInfoCard(Icons.calendar_today, 'Start Date', _formatDate(project.startDate), secondaryViolet)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard(Icons.event, 'End Date', _formatDate(project.expectedEndDate), _getDaysRemaining(project.expectedEndDate) < 0 ? accentRed : (_getDaysRemaining(project.expectedEndDate) <= 30 ? accentOrange : secondaryViolet))),
                ]),
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_getProjectTypeColor(project.projectType ?? '').withOpacity(0.8), _getProjectTypeColor(project.projectType ?? '')]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.apartment, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name ?? 'N/A', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryViolet)),
                        const SizedBox(height: 4),
                        Text((project.projectType ?? 'N/A').replaceAll('_', ' '), style: TextStyle(fontSize: 14, color: _getProjectTypeColor(project.projectType ?? ''), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                if (project.description != null && project.description!.isNotEmpty) ...[
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryViolet)),
                  const SizedBox(height: 8),
                  Text(project.description!, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                  const SizedBox(height: 24),
                ],
                const Text('Project Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryViolet)),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.attach_money, 'Budget', _formatCurrency(project.budget)),
                _buildDetailRow(Icons.person_outline, 'Project Manager', project.projectManager?.name ?? 'N/A'),
                _buildDetailRow(Icons.calendar_today, 'Start Date', _formatDate(project.startDate)),
                _buildDetailRow(Icons.event, 'End Date', _formatDate(project.expectedEndDate)),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectFormPage(project: project)));
                        if (result == true) _loadProjects();
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryViolet, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteProject(project.id!, project.name ?? 'this project');
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryViolet.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: primaryViolet),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryViolet)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}