import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'project_form_page.dart';

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
    'All', 'RESIDENTIAL', 'COMMERCIAL', 'MIXED_USE',
  ];

  final Map<String, Color> projectTypeColors = {
    'RESIDENTIAL': const Color(0xFF4CAF50),
    'COMMERCIAL': const Color(0xFF1A237E),
    'INDUSTRIAL': const Color(0xFFFF6B6B),
    'INFRASTRUCTURE': const Color(0xFF00BFA5),
    'MIXED_USE': const Color(0xFFFFB74D),
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
    setState(() => isLoading = true);
    try {
      final fetchedProjects = await ProjectService.getAllProjects();
      if(mounted) {
        setState(() {
          projects = fetchedProjects;
          filteredProjects = fetchedProjects;
          isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
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
      final success = await ProjectService.deleteProject(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted successfully'), backgroundColor: Colors.green),
          );
          _loadProjects();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete project'), backgroundColor: Colors.red),
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Projects'),
            if (!isLoading)
              Text(
                '${filteredProjects.length} project${filteredProjects.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectFormPage()),
          );
          if (result == true) {
            _loadProjects();
          }
        },
        backgroundColor: const Color(0xFF00BFA5),
        icon: const Icon(Icons.add_business),
        label: const Text('New Project'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : filteredProjects.isEmpty
                ? const Center(child: Text('No projects found.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(filteredProjects[index]);
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
              hintText: 'Search projects by name, manager...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
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
                    onSelected: (selected) {
                      _filterByProjectType(type == 'All' ? null : type);
                    },
                    selectedColor: _getProjectTypeColor(type).withOpacity(0.2),
                    checkmarkColor: _getProjectTypeColor(type),
                    labelStyle: TextStyle(
                      color: isSelected ? _getProjectTypeColor(type) : Colors.grey[700],
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

  Color _getProjectTypeColor(String type) {
    return projectTypeColors[type] ?? const Color(0xFF757575);
  }

  Widget _buildProjectCard(Project project) {
    final daysRemaining = _getDaysRemaining(project.expectedEndDate);
    final isOverdue = daysRemaining < 0;
    final isNearDeadline = daysRemaining >= 0 && daysRemaining <= 30;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        _getProjectTypeColor(project.projectType ?? '').withOpacity(0.8),
                        _getProjectTypeColor(project.projectType ?? ''),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.apartment, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name ?? 'N/A',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getProjectTypeColor(project.projectType ?? '').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (project.projectType ?? 'N/A').replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getProjectTypeColor(project.projectType ?? ''),
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
                        MaterialPageRoute(builder: (context) => ProjectFormPage(project: project)),
                      ).then((result) {
                        if (result == true) {
                          _loadProjects();
                        }
                      });
                    } else if (value == 'delete') {
                      _deleteProject(project.id!, project.name!);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const Divider(height: 24),
            if (project.description != null && project.description!.isNotEmpty) ...[
              Text(
                project.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(child: _buildInfoCard(Icons.attach_money, 'Budget', _formatCurrency(project.budget), const Color(0xFF4CAF50))),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoCard(Icons.person_outline, 'Project Manager', project.projectManager?.name ?? 'N/A', const Color(0xFF1A237E))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoCard(Icons.calendar_today, 'Start Date', _formatDate(project.startDate), const Color(0xFF00BFA5))),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    Icons.event,
                    'End Date',
                    _formatDate(project.expectedEndDate),
                    isOverdue ? Colors.red : isNearDeadline ? Colors.orange : const Color(0xFF00BFA5),
                  ),
                ),
              ],
            ),
            if (project.expectedEndDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isOverdue ? Colors.red : isNearDeadline ? Colors.orange : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning : isNearDeadline ? Icons.access_time : Icons.check_circle,
                      color: isOverdue ? Colors.red : isNearDeadline ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isOverdue ? 'Overdue by ${daysRemaining.abs()} days' : '$daysRemaining days remaining',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? Colors.red : isNearDeadline ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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