import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/building.dart';
import '../models/unit.dart';
import '../services/unit_service.dart';

// A top-level helper function to resolve image URLs, accessible by all widgets in this file.
String getImageUrl(String? path) {
  const String placeholderUrl = 'https://via.placeholder.com/400x300.png?text=No+Image';
  if (path == null || path.isEmpty) {
    return placeholderUrl;
  }
  if (path.startsWith('http')) {
    return path;
  }
  // Make sure to replace 'localhost' with your machine's IP address if testing on a real device.
  return 'http://localhost:8080/images/units/$path';
}

class BuildingUnitsPage extends StatefulWidget {
  final Building building;

  const BuildingUnitsPage({Key? key, required this.building}) : super(key: key);

  @override
  State<BuildingUnitsPage> createState() => _BuildingUnitsPageState();
}

class _BuildingUnitsPageState extends State<BuildingUnitsPage> {
  // State variables for holding and filtering data
  bool _isLoading = true;
  String? _errorMessage;
  List<Unit> _allUnits = [];
  List<Unit> _filteredUnits = [];

  // State variables for filter controls
  final TextEditingController _searchController = TextEditingController();
  String _selectedAvailability = 'All'; // Can be 'All', 'Available', or 'Booked'

  // State variables for price range dropdown filter
  final List<String> _priceRanges = [
    'Any Price',
    'Under \$1000',
    '\$1000 - \$1500',
    '\$1500 - \$2000',
    '\$2000 - \$2500',
    '\$2500+',
  ];
  String _selectedPriceRange = 'Any Price';

  @override
  void initState() {
    super.initState();
    _fetchUnits();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUnits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final units = await UnitService.getUnitsByBuildingId(widget.building.id!);
      if (mounted) {
        setState(() {
          _allUnits = units;
          _filteredUnits = units;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load units: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredUnits = _allUnits.where((unit) {
        final searchMatch =
            unit.unitNumber?.toLowerCase().contains(query) ?? true;

        final availabilityMatch = _selectedAvailability == 'All' ||
            (_selectedAvailability == 'Available' && !unit.isBooked) ||
            (_selectedAvailability == 'Booked' && unit.isBooked);

        final unitPrice = unit.price ?? 0.0;
        bool priceMatch;
        switch (_selectedPriceRange) {
          case 'Any Price':
            priceMatch = true;
            break;
          case 'Under \$1000':
            priceMatch = unitPrice < 1000;
            break;
          case '\$1000 - \$1500':
            priceMatch = unitPrice >= 1000 && unitPrice < 1500;
            break;
          case '\$1500 - \$2000':
            priceMatch = unitPrice >= 1500 && unitPrice < 2000;
            break;
          case '\$2000 - \$2500':
            priceMatch = unitPrice >= 2000 && unitPrice < 2500;
            break;
          case '\$2500+':
            priceMatch = unitPrice >= 2500;
            break;
          default:
            priceMatch = true;
        }

        return searchMatch && availabilityMatch && priceMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Units in ${widget.building.name ?? 'Building'}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Unit Number...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPriceRange,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriceRange = newValue;
                          });
                          _applyFilters();
                        }
                      },
                      items: _priceRanges
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['All', 'Available', 'Booked'].map((status) {
                    return FilterChip(
                      label: Text(status),
                      selected: _selectedAvailability == status,
                      onSelected: (isSelected) {
                        if (isSelected) {
                          setState(() {
                            _selectedAvailability = status;
                          });
                          _applyFilters();
                        }
                      },
                      selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                  onPressed: _fetchUnits,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'))
            ],
          ),
        ),
      );
    }

    if (_allUnits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Units Found'),
            const SizedBox(height: 8),
            Text(
              'There are currently no units listed for this building.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_filteredUnits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_off_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Matching Units'),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // This ListView.builder creates a separate UnitCard for each unit.
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _filteredUnits.length,
      itemBuilder: (context, index) {
        return UnitCard(unit: _filteredUnits[index]);
      },
    );
  }
}

// =========================================================================
// UnitCard Widget - This is the separate white card for each unit
// =========================================================================
class UnitCard extends StatefulWidget {
  final Unit unit;
  const UnitCard({Key? key, required this.unit}) : super(key: key);

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard> {
  int _currentImageIndex = 0;

  String _formatCurrency(double? amount) {
    if (amount == null) return 'N/A';
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch $phoneUri';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not make phone call: $e')),
        );
      }
    }
  }

  void _showPhotoGallery(BuildContext context, int initialIndex) {
    final photoUrls = widget.unit.photoUrls;
    if (photoUrls == null || photoUrls.isEmpty) return;

    final fullImageUrls = photoUrls.map((path) => getImageUrl(path)).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGalleryPage(
          imageUrls: fullImageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrls = widget.unit.photoUrls ?? [];
    final hasImages = photoUrls.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery Section
          if (hasImages)
            _buildImageGallery(context, photoUrls)
          else
            _buildNoImagePlaceholder(),

          // Unit Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit #${widget.unit.unitNumber ?? 'N/A'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(widget.unit.price),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildUnitFeature(Icons.king_bed_outlined,
                        '${widget.unit.bedrooms ?? 0}', 'Beds'),
                    _buildUnitFeature(Icons.bathtub_outlined,
                        '${widget.unit.bathrooms ?? 0}', 'Baths'),
                    _buildUnitFeature(Icons.square_foot_outlined,
                        '${widget.unit.area?.toInt() ?? 0}', 'sqft'),
                  ],
                ),
              ],
            ),
          ),

          // Action Button Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Contact to Book'),
                onPressed: widget.unit.isBooked
                    ? null
                    : () => _makePhoneCall('+8801888118271'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> photoUrls) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showPhotoGallery(context, _currentImageIndex),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.network(
              getImageUrl(photoUrls[_currentImageIndex]),
              key: ValueKey<int>(_currentImageIndex),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _buildNoImagePlaceholder(height: 220),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Chip(
            label: Text(
              widget.unit.isBooked ? 'Booked' : 'Available',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: widget.unit.isBooked
                ? Colors.red.withOpacity(0.8)
                : Colors.green.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        if (photoUrls.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(photoUrls.length, (index) {
                    final isActive = _currentImageIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _currentImageIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 48 : 40,
                        height: isActive ? 48 : 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.white,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(getImageUrl(photoUrls[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoImagePlaceholder({double height = 220}) {
    return Container(
      height: height,
      color: Colors.grey[300],
      child: Center(
        child:
        Icon(Icons.apartment_outlined, size: 60, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildUnitFeature(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700], size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

// =========================================================================
// PhotoGalleryPage Widget (No changes needed)
// =========================================================================
class PhotoGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const PhotoGalleryPage({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  panEnabled: true,
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(
                        child: Icon(Icons.error, color: Colors.red)),
                  ),
                );
              },
            ),
            Positioned(
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _currentIndex > 0
                    ? () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
                    : null,
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3)),
              ),
            ),
            Positioned(
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: _currentIndex < widget.imageUrls.length - 1
                    ? () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
                    : null,
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}