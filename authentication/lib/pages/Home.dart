import 'dart:ui';
import 'package:crems/pages/SignIn.dart';
import 'package:flutter/material.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class AppTheme {
  static const kPrimaryColor = Color(0xFF6A1B9A);
  static const kAccentColor = Color(0xFFF57C00);
  static const kBackgroundColor = Color(0xFFF7F8FC);
  static const kTextColor = Color(0xFF232323);
  static const kSecondaryTextColor = Colors.black54;
  static const kFooterColor = Color(0xFF2C3E50);

  static const double kDefaultPadding = 20.0;
  static const double kDesktopBreakpoint = 1024.0;
  static final kDefaultBorderRadius = BorderRadius.circular(16);
  static final kDefaultBoxShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static TextTheme get textTheme => const TextTheme(
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      color: kTextColor,
      fontSize: 32,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      color: kTextColor,
      fontSize: 24,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: kTextColor,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: kTextColor,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: kSecondaryTextColor,
      fontSize: 14,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 14,
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _heroController = PageController(viewportFraction: 0.9);
  int _navIndex = 0;

  final List<Map<String, dynamic>> _properties = [
    {
      'title': 'Modern Downtown Apartment',
      'price': '\$425,000',
      'location': 'Manhattan, NY',
      'beds': 2,
      'baths': 2,
      'sqft': '1,200',
      'image':
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'rating': 4.8,
      'type': 'For Sale',
    },
    {
      'title': 'Luxury Waterfront Villa',
      'price': '\$2,850,000',
      'location': 'Miami Beach, FL',
      'beds': 4,
      'baths': 4,
      'sqft': '3,500',
      'image':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'rating': 4.9,
      'type': 'For Sale',
    },
    {
      'title': 'Cozy City Studio',
      'price': '\$2,100/mo',
      'location': 'Brooklyn Heights, NY',
      'beds': 1,
      'baths': 1,
      'sqft': '750',
      'image':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'rating': 4.6,
      'type': 'For Rent',
    },
    {
      'title': 'Suburban Family Home',
      'price': '\$780,000',
      'location': 'Austin, TX',
      'beds': 3,
      'baths': 2,
      'sqft': '2,400',
      'image':
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'rating': 4.7,
      'type': 'For Sale',
    },
  ];
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Apartments',
      'count': '1,245 Properties',
      'icon': Icons.apartment_rounded,
    },
    {
      'name': 'Houses',
      'count': '856 Properties',
      'icon': Icons.house_siding_rounded,
    },
    {
      'name': 'Condos',
      'count': '642 Properties',
      'icon': Icons.location_city_rounded,
    },
    {'name': 'Villas', 'count': '328 Properties', 'icon': Icons.villa_rounded},
  ];
  final List<Map<String, dynamic>> _agents = [
    {
      'name': 'Johnathan Doe',
      'title': 'Senior Broker',
      'image': 'https://randomuser.me/api/portraits/men/85.jpg',
    },
    {
      'name': 'Jane Smith',
      'title': 'Listing Agent',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
    },
    {
      'name': 'Michael Chen',
      'title': 'Rental Specialist',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
    {
      'name': 'Emily Rodriguez',
      'title': 'Commercial Expert',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
    },
  ];

  // NEW MOCK DATA
  final List<Map<String, dynamic>> _neighborhoods = [
    {
      'name': 'Greenwich Village',
      'listings': 124,
      'image':
          'https://images.unsplash.com/photo-1605276374104-5de67d609205?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Beverly Hills',
      'listings': 88,
      'image':
          'https://images.unsplash.com/photo-1594493744959-158a71971dc0?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'South Beach',
      'listings': 212,
      'image':
          'https://images.unsplash.com/photo-1541882236942-5369a04d3d3a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    },
  ];
  final List<Map<String, dynamic>> _testimonials = [
    {
      'quote':
          'CREMS made finding our dream home a breeze. Their agents are top-notch!',
      'name': 'The Johnson Family',
      'image': 'https://randomuser.me/api/portraits/women/34.jpg',
    },
    {
      'quote':
          'Selling my property was fast and seamless. I got a fantastic price thanks to their expertise.',
      'name': 'David Chen',
      'image': 'https://randomuser.me/api/portraits/men/46.jpg',
    },
  ];
  final List<Map<String, dynamic>> _blogPosts = [
    {
      'title': '5 Essential Tips for First-Time Homebuyers',
      'category': 'Buying Guide',
      'image':
          'https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Navigating the 2024 Housing Market Trends',
      'category': 'Market Analysis',
      'image':
          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'How to Stage Your Home for a Quick Sale',
      'category': 'Selling Tips',
      'image':
          'https://images.unsplash.com/photo-1600585152220-90363fe7e115?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.of(context).size.width >= AppTheme.kDesktopBreakpoint;

    return Scaffold(
      backgroundColor: AppTheme.kBackgroundColor,
      appBar: _buildAppBar(isDesktop, context),
      body: _buildBody(isDesktop),
      floatingActionButton: isDesktop ? null : _buildFloatingActionButton(),
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.kPrimaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home_work_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text('CREMS', style: AppTheme.textTheme.headlineSmall),
        ],
      ),
      actions: [
        if (isDesktop) ...[
          _DesktopNavItem(
            title: 'Home',
            isSelected: _navIndex == 0,
            onTap: () => setState(() => _navIndex = 0),
          ),
          _DesktopNavItem(
            title: 'Search',
            isSelected: _navIndex == 1,
            onTap: () => setState(() => _navIndex = 1),
          ),
          _DesktopNavItem(
            title: 'Sell',
            isSelected: _navIndex == 2,
            onTap: () => setState(() => _navIndex = 2),
          ),
          _DesktopNavItem(
            title: 'Blog',
            isSelected: _navIndex == 3,
            onTap: () => setState(() => _navIndex = 3),
          ),
          const SizedBox(width: 16),
        ],
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.kTextColor,
          ),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: AppTheme.kDefaultPadding),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
            ),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: Text(isDesktop ? 'Log In / Sign Up' : 'Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 16,
                vertical: isDesktop ? 18 : 12,
              ),
              elevation: 2,
              shadowColor: AppTheme.kPrimaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(bool isDesktop) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(
                    properties: _properties,
                    pageController: _heroController,
                  ),
                  _Section(
                    title: "Explore by Property Type",
                    child: Wrap(
                      spacing: AppTheme.kDefaultPadding,
                      runSpacing: AppTheme.kDefaultPadding,
                      children: _categories
                          .map(
                            (cat) => SizedBox(
                              width: 250,
                              child: _CategoryCard(category: cat),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _Section(
                    title: "Featured Properties",
                    onViewAll: () {},
                    child: isDesktop
                        ? _buildPropertiesGridView()
                        : _buildPropertiesListView(),
                  ),
                  _Section(
                    title: "Featured Neighborhoods",
                    onViewAll: () {},
                    child: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _neighborhoods.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : AppTheme.kDefaultPadding,
                          ),
                          child: _NeighborhoodCard(
                            neighborhood: _neighborhoods[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const _HomeValueCtaSection(),
                  _Section(
                    title: "What Our Clients Say",
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          // Mobile: Vertical list
                          return Column(
                            children: _testimonials
                                .map(
                                  (t) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppTheme.kDefaultPadding,
                                    ),
                                    child: _TestimonialCard(testimonial: t),
                                  ),
                                )
                                .toList(),
                          );
                        } else {
                          // Desktop: Horizontal list
                          return Row(
                            children: _testimonials
                                .map(
                                  (t) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            AppTheme.kDefaultPadding / 2,
                                      ),
                                      child: _TestimonialCard(testimonial: t),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }
                      },
                    ),
                  ),
                  _Section(
                    title: "Meet Our Expert Agents",
                    onViewAll: () {},
                    child: SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _agents.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : AppTheme.kDefaultPadding,
                            bottom: AppTheme.kDefaultPadding / 2,
                          ),
                          child: SizedBox(
                            width: 180,
                            child: _AgentCard(agent: _agents[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _Section(
                    title: "Insights From Our Blog",
                    onViewAll: () {},
                    child: SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _blogPosts.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : AppTheme.kDefaultPadding,
                            bottom: AppTheme.kDefaultPadding / 2,
                          ),
                          child: SizedBox(
                            width: 300,
                            child: _BlogCard(post: _blogPosts[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _AppFooter(),
        ],
      ),
    );
  }

  Widget _buildPropertiesGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppTheme.kDefaultPadding,
        mainAxisSpacing: AppTheme.kDefaultPadding,
      ),
      itemCount: _properties.length,
      itemBuilder: (context, index) =>
          _PropertyCard(property: _properties[index]),
    );
  }

  Widget _buildPropertiesListView() {
    return SizedBox(
      height: 380,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _properties.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 0 : AppTheme.kDefaultPadding,
            bottom: AppTheme.kDefaultPadding / 2,
          ),
          child: SizedBox(
            width: 300,
            child: _PropertyCard(property: _properties[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() => FloatingActionButton(
    onPressed: () {},
    backgroundColor: AppTheme.kPrimaryColor,
    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
  );

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _navIndex,
      onTap: (index) => setState(() => _navIndex = index),
      selectedItemColor: AppTheme.kPrimaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_rounded),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_rounded),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _NeighborhoodCard extends StatelessWidget {
  final Map<String, dynamic> neighborhood;
  const _NeighborhoodCard({required this.neighborhood});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.kDefaultBorderRadius,
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Stack(
          children: [
            _NetworkImageWithLoader(imageUrl: neighborhood['image']),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Positioned(
              bottom: AppTheme.kDefaultPadding,
              left: AppTheme.kDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    neighborhood['name'],
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${neighborhood['listings']} Listings',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeValueCtaSection extends StatelessWidget {
  const _HomeValueCtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.kDefaultPadding),
      padding: const EdgeInsets.all(AppTheme.kDefaultPadding * 2),
      decoration: BoxDecoration(
        color: AppTheme.kPrimaryColor.withOpacity(0.1),
        borderRadius: AppTheme.kDefaultBorderRadius,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thinking of Selling?",
                  style: TextStyle(
                    color: AppTheme.kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Find Out Your Home's Value",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kTextColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Get a free, instant, and accurate home valuation from our local experts.",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.kSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.kDefaultPadding),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Get Estimate'),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final Map<String, dynamic> testimonial;
  const _TestimonialCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.kDefaultBorderRadius,
        boxShadow: AppTheme.kDefaultBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppTheme.kPrimaryColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            '"${testimonial['quote']}"',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(testimonial['image']),
              ),
              const SizedBox(width: 12),
              Text(testimonial['name'], style: AppTheme.textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _BlogCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.kDefaultBorderRadius,
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NetworkImageWithLoader(imageUrl: post['image'], height: 150),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['category'].toUpperCase(),
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['title'],
                  style: AppTheme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  'Read More →',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.kAccentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppFooter extends StatelessWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.kFooterColor,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.kDefaultPadding * 2,
        horizontal: AppTheme.kDefaultPadding,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(text: 'About Us'),
              _FooterLink(text: 'Contact'),
              _FooterLink(text: 'Careers'),
              _FooterLink(text: 'Privacy Policy'),
            ],
          ),
          const SizedBox(height: AppTheme.kDefaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.facebook, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.telegram, color: Colors.white),
              ),
              // Placeholder for Twitter/X
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt, color: Colors.white),
              ),
              // Placeholder for Instagram
            ],
          ),
          const SizedBox(height: AppTheme.kDefaultPadding),
          Text(
            '© ${DateTime.now().year} CREMS. All Rights Reserved.',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextButton(
        onPressed: () {},
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onViewAll;
  const _Section({required this.title, required this.child, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTheme.textTheme.headlineSmall),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text(
                    'View All',
                    style: TextStyle(color: AppTheme.kPrimaryColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.kDefaultPadding),
          child,
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.properties, required this.pageController});

  final List<Map<String, dynamic>> properties;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.of(context).size.width >= AppTheme.kDesktopBreakpoint;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
      child: AspectRatio(
        aspectRatio: isDesktop ? 4 / 1.2 : 1.5 / 1,
        child: ClipRRect(
          borderRadius: AppTheme.kDefaultBorderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: properties.length,
                itemBuilder: (context, index) => _NetworkImageWithLoader(
                  imageUrl: properties[index]['image'],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: AppTheme.kDefaultPadding * 1.5,
                left: AppTheme.kDefaultPadding * 1.5,
                right: AppTheme.kDefaultPadding * 1.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Find Your Dream Home",
                      style: AppTheme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Discover a place you'll love to live",
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppTheme.kDefaultPadding),
                    const _SearchBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const _DesktopNavItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTheme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? AppTheme.kPrimaryColor
                    : AppTheme.kTextColor,
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                height: 2,
                width: 24,
                decoration: BoxDecoration(
                  color: AppTheme.kPrimaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.kDefaultBoxShadow,
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for location, price, or property type...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.kPrimaryColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kPrimaryColor.withOpacity(0.1),
              foregroundColor: AppTheme.kPrimaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.kDefaultBorderRadius,
        boxShadow: AppTheme.kDefaultBoxShadow,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(category['icon'], size: 32, color: AppTheme.kPrimaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category['name'], style: AppTheme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(category['count'], style: AppTheme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  const _PropertyCard({required this.property});

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: () {},
        borderRadius: AppTheme.kDefaultBorderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.kDefaultBorderRadius,
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: AppTheme.kPrimaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : AppTheme.kDefaultBoxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _NetworkImageWithLoader(
                      imageUrl: widget.property['image'],
                      height: 180,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Chip(
                      label: Text(
                        widget.property['type'],
                        style: AppTheme.textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: widget.property['type'] == 'For Sale'
                          ? AppTheme.kAccentColor
                          : AppTheme.kPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        widget.property['title'],
                        style: AppTheme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppTheme.kSecondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.property['location'],
                              style: AppTheme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPropertyDetail(
                            Icons.king_bed_outlined,
                            '${widget.property['beds']} Beds',
                          ),
                          _buildPropertyDetail(
                            Icons.bathtub_outlined,
                            '${widget.property['baths']} Baths',
                          ),
                          _buildPropertyDetail(
                            Icons.square_foot_outlined,
                            '${widget.property['sqft']} sqft',
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.property['price'],
                            style: AppTheme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.kPrimaryColor,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.property['rating']}',
                                style: AppTheme.textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyDetail(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 18, color: AppTheme.kPrimaryColor),
      const SizedBox(width: 6),
      Text(text, style: AppTheme.textTheme.bodyMedium),
    ],
  );
}

class _AgentCard extends StatelessWidget {
  final Map<String, dynamic> agent;
  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.kDefaultBorderRadius,
        boxShadow: AppTheme.kDefaultBoxShadow,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(agent['image']),
          ),
          const SizedBox(height: 16),
          Text(
            agent['name'],
            style: AppTheme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(agent['title'], style: AppTheme.textTheme.bodyMedium),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.phone_outlined,
                  color: AppTheme.kPrimaryColor,
                  size: 20,
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: AppTheme.kPrimaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final double? height;
  const _NetworkImageWithLoader({required this.imageUrl, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              color: AppTheme.kPrimaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
          ),
        );
      },
    );
  }
}
