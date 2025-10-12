import 'package:crems/pages/project_form_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../services/project_service.dart';


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

  // Project type options
  final List<String> projectTypes = [
    'All',
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'INFRASTRUCTURE',
    'MIXED_USE',
  ];

  // Project type colors for badges
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
        // Apply search filter
        final matchesSearch = project.name!.toLowerCase().contains(query) ||
            (project.description ?? '').toLowerCase().contains(query) ||
            (project.projectManager?.name ?? '').toLowerCase().contains(query);

        // Apply project type filter
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
      setState(() {
        projects = fetchedProjects;
        filteredProjects = fetchedProjects;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load projects: $e';
        isLoading = false;
      });
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
      final success = await ProjectService.deleteProject(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Project deleted successfully'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadProjects();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Failed to delete project')),
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

  String _formatCurrency(int? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
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
            MaterialPageRoute(
              builder: (context) => const ProjectFormPage(),
            ),
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
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects by name, manager...',
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

          // Project Type Filter Chips
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
                    children: projectTypes.map((type) {
                      final isSelected = selectedProjectType == type ||
                          (selectedProjectType == null && type == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type.replaceAll('_', ' ')),
                          selected: isSelected,
                          onSelected: (selected) {
                            _filterByProjectType(type == 'All' ? null : type);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: _getProjectTypeColor(type).withOpacity(0.2),
                          checkmarkColor: _getProjectTypeColor(type),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? _getProjectTypeColor(type)
                                : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? _getProjectTypeColor(type)
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

          // Projects List
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
                      onPressed: _loadProjects,
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
                : filteredProjects.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apartment,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    projects.isEmpty
                        ? 'No projects found'
                        : 'No matching projects',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    projects.isEmpty
                        ? 'Create your first project to get started'
                        : 'Try adjusting your search or filters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (projects.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _filterByProjectType(null);
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
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
                return _buildProjectCard(project);
              },
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
                builder: (context) => ProjectFormPage(project: project),
              ),
            );
            if (result == true) {
              _loadProjects();
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getProjectTypeColor(project.projectType ?? '')
                                .withOpacity(0.8),
                            _getProjectTypeColor(project.projectType ?? ''),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.apartment,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name ?? 'N/A',
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
                              color: _getProjectTypeColor(project.projectType ?? '')
                                  .withOpacity(0.1),
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
                                      ProjectFormPage(project: project),
                                ),
                              );
                              if (result == true) {
                                _loadProjects();
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
                                _deleteProject(project.id!, project.name!),
                            tooltip: 'Delete',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if (project.description != null &&
                    project.description!.isNotEmpty) ...[
                  Text(
                    project.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],

                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.attach_money,
                        'Budget',
                        _formatCurrency(project.budget),
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.person_outline,
                        'Manager',
                        project.projectManager?.name ?? 'N/A',
                        const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.calendar_today,
                        'Start Date',
                        _formatDate(project.startDate),
                        const Color(0xFF00BFA5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.event,
                        'End Date',
                        _formatDate(project.expectedEndDate),
                        isOverdue
                            ? const Color(0xFFFF6B6B)
                            : isNearDeadline
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFF00BFA5),
                      ),
                    ),
                  ],
                ),

                // Timeline/Progress Indicator
                if (project.expectedEndDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? const Color(0xFFFF6B6B).withOpacity(0.1)
                          : isNearDeadline
                          ? const Color(0xFFFFB74D).withOpacity(0.1)
                          : const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOverdue
                              ? Icons.warning
                              : isNearDeadline
                              ? Icons.access_time
                              : Icons.check_circle,
                          color: isOverdue
                              ? const Color(0xFFFF6B6B)
                              : isNearDeadline
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isOverdue
                                ? 'Overdue by ${daysRemaining.abs()} days'
                                : isNearDeadline
                                ? '$daysRemaining days remaining'
                                : '$daysRemaining days until deadline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOverdue
                                  ? const Color(0xFFFF6B6B)
                                  : isNearDeadline
                                  ? const Color(0xFFFFB74D)
                                  : const Color(0xFF4CAF50),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
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