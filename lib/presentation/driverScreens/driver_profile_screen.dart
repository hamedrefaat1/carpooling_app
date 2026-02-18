import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DriverProfileScreen extends StatefulWidget {
  final bool isDriver;
  
  const DriverProfileScreen({super.key, this.isDriver = true});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SafeArea(
      child: Scaffold(
       backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.background,
        body: CustomScrollView(
          slivers: [
            // AppBar with background image
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/profile_bg.png',
                      fit: BoxFit.cover,
                      color: isDark 
                        ? Colors.blue[900]!.withOpacity(0.8)
                        : Colors.blue[800]!.withOpacity(0.7),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
      
            // Profile content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User information
                    _buildProfileHeader(context),
                    const SizedBox(height: 24),
      
                    // Statistics
                    _buildStatsSection(context),
                    const SizedBox(height: 24),
      
                    // Rating
                    _buildRatingSection(context),
                    const SizedBox(height: 24),
      
                    // Tabs
                    _buildTabBar(context),
                    const SizedBox(height: 16),
      
                    // Tab content
                    _buildTabContent(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile picture
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=100&q=80',
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Basic information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hamed Refaat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isDriver ? 'Professional Driver' : 'Regular Passenger',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Cairo, Egypt',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.directions_car, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    widget.isDriver ? 'Hyundai Accent - 2022' : 'Travels regularly',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            widget.isDriver ? 'Trips' : 'Trips',
            '128',
            Icons.route,
          ),
          _buildStatItem(
            context,
            'Rating',
            '4.8',
            Icons.star,
          ),
          _buildStatItem(
            context,
            widget.isDriver ? 'Passengers' : 'Friends',
            '89',
            widget.isDriver ? Icons.people : Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue[900] : Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDark ? Colors.blue[200] : Colors.blue[700], size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Rating',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Average rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: 4.8,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {},
                    ignoreGestures: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(128 reviews)',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Rating distribution
              Expanded(
                child: Column(
                  children: [
                    _buildRatingProgress(context, 5, 0.75),
                    _buildRatingProgress(context, 4, 0.15),
                    _buildRatingProgress(context, 3, 0.07),
                    _buildRatingProgress(context, 2, 0.02),
                    _buildRatingProgress(context, 1, 0.01),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingProgress(BuildContext context, int stars, double percentage) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black,
          )),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12, 
              color: isDark ? Colors.grey[400] : Colors.grey[600]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color:  isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(context, 0, 'Information'),
          _buildTab(context, 1, widget.isDriver ? 'Vehicle' : 'Preferences'),
          _buildTab(context, 2, 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedTab == index 
              ? (isDark ? Colors.blue[900] : Colors.blue[50]) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: _selectedTab == index
                ? Border.all(color: Colors.blue, width: 1)
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTab == index 
                ? (isDark ? Colors.blue[200] : Colors.blue[700]) 
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return _buildInfoTab(context);
      case 1:
        return widget.isDriver ? _buildVehicleTab(context) : _buildPreferencesTab(context);
      case 2:
        return _buildReviewsTab(context);
      default:
        return _buildInfoTab(context);
    }
  }

  Widget _buildInfoTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem(context, 'Email', 'ahmed@example.com', Icons.email),
        _buildInfoItem(context, 'Phone', '+20123456789', Icons.phone),
        _buildInfoItem(context, 'Join Date', 'January 2023', Icons.calendar_today),
        _buildInfoItem(
          context,
          'Languages',
          'Arabic, English',
          Icons.language,
        ),
        if (widget.isDriver)
          _buildInfoItem(context, 'Driver License', '123456789', Icons.credit_card),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.blue[200] : Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:  isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.directions_car, size: 60, color: isDark ? Colors.blue[200] : Colors.blue[700]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hyundai Accent',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('2022 - White', style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
              const SizedBox(height: 16),
              _buildVehicleInfoItem(context, 'Plate Number', 'ABC 1234'),
              _buildVehicleInfoItem(context, 'Fuel Type', 'Gasoline'),
              _buildVehicleInfoItem(context, 'Seats', '4 seats'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoItem(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600]
          )),
          Text(value, style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          )),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // Add passenger preferences here
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return Column(
      children: [
        _buildReviewItem(
          context,
          'Mohamed Ali',
          'Very comfortable trip and professional driver',
          5,
          '3 days ago',
        ),
        _buildReviewItem(
          context,
          'Fatma Ahmed',
          'Clean vehicle and accurate timing',
          4,
          '1 week ago',
        ),
        _buildReviewItem(
          context,
          'Khaled Mostafa',
          'Good experience overall',
          4,
          '2 weeks ago',
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context, String name, String comment, int rating, String time) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=$name&background=random',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: rating.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 16,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                      ignoreGestures: true,
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12, 
                  color: isDark ? Colors.grey[400] : Colors.grey[500]
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}