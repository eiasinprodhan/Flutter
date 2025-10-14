import 'package:flutter/material.dart';
import '../models/building.dart';
import '../models/employee.dart';
import '../models/project.dart';
import '../services/auth_service.dart';
import '../services/building_service.dart';
import '../services/employee_service.dart';
import '../services/project_service.dart';
import 'building_units_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

// --- VIOLET COLOR PALETTE ---
const Color primaryViolet = Color(0xFF673AB7); // DeepPurple 500
const Color secondaryViolet = Color(0xFF9575CD); // DeepPurple 300
const Color backgroundLight = Color(0xFFF5F5F5); // Grey 100
const Color cardColor = Colors.white;
const Color darkTextColor = Color(0xFF333333);
const Color subtleTextColor = Color(0xFF666666);
// --- END OF PALETTE ---

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _homePageData;
  final PageController _testimonialController = PageController();

  // --- STATE FOR SEARCH AND FILTER ---
  final TextEditingController _searchController = TextEditingController();
  List<Building> _allBuildings = [];
  List<Building> _filteredBuildings = [];
  String? _selectedType; // This will now store 'RESIDENTIAL', 'COMMERCIAL', etc.
  int _currentTestimonialPage = 0;
  // --- END OF STATE ---

  final List<Map<String, String>> testimonials = [
    {'name': 'Emma Wilson', 'role': 'Property Owner', 'feedback': 'Outstanding service! The team helped me find my dream home within my budget. Professional, responsive, and truly dedicated.', 'image': 'https://randomuser.me/api/portraits/women/4.jpg'},
    {'name': 'David Martinez', 'role': 'First-time Buyer', 'feedback': 'As a first-time buyer, I was nervous about the process. The agents made everything smooth, simple, and easy to understand.', 'image': 'https://randomuser.me/api/portraits/men/5.jpg'},
    {'name': 'Sarah Lee', 'role': 'Investor', 'feedback': 'Incredibly professional and knowledgeable. They provided valuable insights that led to a great investment for my portfolio.', 'image': 'https://randomuser.me/api/portraits/women/6.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _homePageData = _loadHomePageData();
    _searchController.addListener(_runFilter);
    _testimonialController.addListener(() {
      if (_testimonialController.page?.round() != _currentTestimonialPage) {
        setState(() => _currentTestimonialPage = _testimonialController.page!.round());
      }
    });
  }

  // --- UPDATED SEARCH AND FILTER LOGIC ---
  void _runFilter() {
    List<Building> results = [];
    final enteredKeyword = _searchController.text.toLowerCase();

    if (enteredKeyword.isEmpty && _selectedType == null) {
      // If no filter is active, show the default list
      results = _allBuildings.take(5).toList();
    } else {
      results = _allBuildings.where((building) {
        final nameMatch = building.name?.toLowerCase().contains(enteredKeyword) ?? false;
        final locationMatch = building.location?.toLowerCase().contains(enteredKeyword) ?? false;
        final typeMatch = _selectedType == null || building.type == _selectedType;

        return (nameMatch || locationMatch) && typeMatch;
      }).toList();
    }

    setState(() {
      _filteredBuildings = results;
    });
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedType = null;
    });
    // The listener on _searchController will call _runFilter automatically
  }

  // --- END OF SEARCH AND FILTER LOGIC ---

  Future<Map<String, dynamic>> _loadHomePageData() async {
    try {
      final results = await Future.wait([
        BuildingService.getAllBuildings(),
        EmployeeService.getEmployeesByRole('PROJECT_MANAGER'),
        ProjectService.getAllProjects(),
      ]);
      return {'buildings': results[0] as List<Building>, 'agents': results[1] as List<Employee>, 'projects': results[2] as List<Project>};
    } catch (e) {
      debugPrint('Failed to load homepage data: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _testimonialController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getImageUrl(String? path, String type) {
    if (path == null || path.isEmpty) return 'https://via.placeholder.com/400x300.png?text=No+Image';
    if (path.startsWith('http')) return path;
    return 'http://localhost:8080/images/$type/$path';
  }

  String _formatBuildingType(String? type) {
    if (type == null) return 'N/A';
    return type.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final isFilterActive = _searchController.text.isNotEmpty || _selectedType != null;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homePageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryViolet));
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          }

          if (_allBuildings.isEmpty) {
            _allBuildings = snapshot.data!['buildings'];
            _filteredBuildings = _allBuildings.take(5).toList();
          }
          final List<Employee> agents = snapshot.data!['agents'];

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(child: _buildHeroSection(context)),
              SliverToBoxAdapter(child: _buildSectionHeader(isFilterActive ? "Search Results" : "Featured Properties", isFilterActive ? "Clear" : "View All", onActionTap: isFilterActive ? _clearFilters : null)),
              SliverToBoxAdapter(child: _buildPropertiesList()),
              SliverToBoxAdapter(child: _buildSectionHeader("Explore by Type", "")),
              SliverToBoxAdapter(child: _buildExploreByType()),
              SliverToBoxAdapter(child: _buildSectionHeader("Meet Our Top Agents", "View All")),
              SliverToBoxAdapter(child: _buildAgentsSection(agents)),
              SliverToBoxAdapter(child: _buildSectionHeader("What Our Clients Say", "")),
              SliverToBoxAdapter(child: _buildTestimonialsSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: backgroundLight,
      elevation: 0,
      pinned: true,
      floating: true,
      title: const Row(
        children: [
          Icon(Icons.home_work_rounded, color: primaryViolet, size: 28),
          SizedBox(width: 8),
          Text(
            'CREMS',
            style: TextStyle(color: primaryViolet, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_outlined, color: Colors.grey[800], size: 26),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthService.isLoggedIn() ? const ProfilePage() : const LoginPage()),
              );
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: primaryViolet.withOpacity(0.1),
              child: Icon(AuthService.isLoggedIn() ? Icons.person : Icons.login, size: 18, color: primaryViolet),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find Your",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: subtleTextColor, fontWeight: FontWeight.w400),
          ),
          Text(
            "Dream Property",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: primaryViolet, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or location...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: primaryViolet),
              suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () => _searchController.clear()) : null,
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, {VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: darkTextColor),
          ),
          if (actionText.isNotEmpty)
            InkWell(
              onTap: onActionTap,
              child: Text(
                actionText,
                style: const TextStyle(color: secondaryViolet, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPropertiesList() {
    if (_filteredBuildings.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('No Properties Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text('Try adjusting your search or filters.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredBuildings.length,
        itemBuilder: (context, index) {
          return _buildPropertyCard(_filteredBuildings[index]);
        },
      ),
    );
  }

  Widget _buildPropertyCard(Building building) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BuildingUnitsPage(building: building)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      _getImageUrl(building.photo, 'buildings'),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: Icon(Icons.business, size: 50, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Chip(
                      label: Text(_formatBuildingType(building.type)),
                      backgroundColor: secondaryViolet,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name ?? 'Untitled Building',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            building.location ?? 'No location',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPropertyFeature(Icons.layers_outlined, '${building.floorCount ?? 0} Floors'),
                        const SizedBox(width: 12),
                        _buildPropertyFeature(Icons.meeting_room_outlined, '${building.unitCount ?? 0} Units'),
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

  Widget _buildPropertyFeature(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildExploreByType() {
    final List<Map<String, dynamic>> types = [
      {'icon': Icons.apartment, 'label': 'Residential', 'backendType': 'RESIDENTIAL'},
      {'icon': Icons.store, 'label': 'Commercial', 'backendType': 'COMMERCIAL'},
      {'icon': Icons.business_center, 'label': 'Mixed-Use', 'backendType': 'MIXED_USE'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _selectedType == type['backendType'];

          return InkWell(
            onTap: () {
              setState(() {
                _selectedType = isSelected ? null : type['backendType'] as String;
              });
              _runFilter();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryViolet : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      border: isSelected ? Border.all(color: secondaryViolet, width: 2) : null,
                    ),
                    child: Icon(type['icon'] as IconData, color: isSelected ? Colors.white : primaryViolet, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type['label'] as String,
                    style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgentsSection(List<Employee> agents) {
    final topAgents = agents.take(5).toList();
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: topAgents.length,
        itemBuilder: (context, index) {
          return _buildAgentAvatar(topAgents[index]);
        },
      ),
    );
  }

  Widget _buildAgentAvatar(Employee agent) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: secondaryViolet.withOpacity(0.2),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(_getImageUrl(agent.photo, 'employees')),
              onBackgroundImageError: (_, __) {},
              child: agent.photo == null || agent.photo!.isEmpty ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            agent.name?.split(' ').first ?? 'Agent',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _testimonialController,
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              return _buildTestimonialCard(testimonials[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            testimonials.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentTestimonialPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentTestimonialPage == index ? primaryViolet : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(Map<String, String> testimonial) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: secondaryViolet, size: 30),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              '"' + testimonial['feedback']! + '"',
              style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(testimonial['image']!)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(testimonial['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(testimonial['role']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text('Failed to Load Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryViolet),
              onPressed: () => setState(() {
                _homePageData = _loadHomePageData();
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}