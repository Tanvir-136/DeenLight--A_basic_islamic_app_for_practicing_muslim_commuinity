import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/location_provider.dart';
import '../models/location.dart';
import 'tasbeeh_screen.dart';
import 'settings_screen.dart';
import 'hijri_calendar_screen.dart';
import 'prayer_times_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize location when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().initializeLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Location Dropdown
          SliverAppBar(
            expandedHeight: 50.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green[700]!, Colors.green[500]!],
                  ),
                ),
              ),
            ),
            title: _buildLocationDropdown(locationProvider),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
            ],
          ),

          // Current Date and Prayer Time Card
          SliverToBoxAdapter(
            child: _buildDateTimeCard(context, locationProvider),
          ),

          // Features Grid
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  context,
                  Icons.access_time,
                  AppLocalizations.of(context).translate('prayerTimes'),
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrayerTimesScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  Icons.psychology,
                  AppLocalizations.of(context).translate('tasbeeh'),
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TasbeehScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  Icons.handshake,
                  AppLocalizations.of(context).translate('dua'),
                  Colors.orange,
                  () {
                    _showComingSoon(context);
                  },
                ),
                _buildFeatureCard(
                  context,
                  Icons.calendar_today,
                  AppLocalizations.of(context).translate('hijriCalendar'),
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HijriCalendarScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  Icons.explore,
                  AppLocalizations.of(context).translate('qibla'),
                  Colors.red,
                  () {
                    _showComingSoon(context);
                  },
                ),
                _buildFeatureCard(
                  context,
                  Icons.menu_book,
                  'Quran',
                  Colors.teal,
                  () {
                    _showComingSoon(context);
                  },
                ),
              ]),
            ),
          ),

          // Daily Hadith
          SliverToBoxAdapter(
            child: _buildDailyHadith(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown(LocationProvider locationProvider) {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.white, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: locationProvider.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : PopupMenuButton<Location>(
                  icon: Row(
                    children: [
                      Expanded(
                        child: Text(
                          locationProvider.currentLocation?.toString() ?? 'Select Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                  onSelected: (location) {
                    if (location.id == 'current_location') {
                      // Get current location
                      locationProvider.getCurrentLocation();
                    } else {
                      locationProvider.changeLocation(location);
                    }
                  },
                  itemBuilder: (context) {
                    final menuItems = <PopupMenuEntry<Location>>[];

                    // Current Location option
                    menuItems.add(
                      PopupMenuItem<Location>(
                        value: Location(
                          id: 'current_location',
                          name: 'Current Location',
                          country: '',
                          latitude: 0,
                          longitude: 0,
                          lastUpdated: DateTime.now(),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Use Current Location'),
                            if (locationProvider.isGettingLocation)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                    );

                    menuItems.add(PopupMenuDivider());

                    // Available locations
                    for (final location in locationProvider.availableLocations) {
                      menuItems.add(
                        PopupMenuItem<Location>(
                          value: location,
                          child: Row(
                            children: [
                              Icon(Icons.location_city, size: 20, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location.toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (locationProvider.currentLocation?.id == location.id)
                                Icon(Icons.check, size: 16, color: Colors.green),
                            ],
                          ),
                        ),
                      );
                    }

                    return menuItems;
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateTimeCard(BuildContext context, LocationProvider locationProvider) {
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';
    
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[600]!, Colors.green[400]!],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today in ${locationProvider.currentLocation?.city ?? locationProvider.currentLocation?.name ?? ''}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Next Prayer: Fajr',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '05:30', // Example prayer time
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Function onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.9)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyHadith(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Daily Hadith',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '"The best among you are those who have the best manners and character."',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '- Prophet Muhammad (PBUH)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Coming Soon'),
          content: Text('This feature will be available in the next update.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}