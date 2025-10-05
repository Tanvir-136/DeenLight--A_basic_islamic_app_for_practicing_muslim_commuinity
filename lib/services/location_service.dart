import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';

class LocationService {
  static const String _selectedLocationKey = 'selected_location';
  static const String _cachedLocationsKey = 'cached_locations';
  
  // Get current location using GPS
  static Future<Location> getCurrentLocation() async {
    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Reverse geocode to get address
      final address = await _reverseGeocode(position.latitude, position.longitude);
      
      return Location(
        id: 'current_${DateTime.now().millisecondsSinceEpoch}',
        name: address['name'] ?? 'Current Location',
        country: address['country'] ?? 'Unknown',
        state: address['state'],
        city: address['city'],
        latitude: position.latitude,
        longitude: position.longitude,
        lastUpdated: DateTime.now(),
        isCurrentLocation: true,
      );
    } catch (e) {
      print('GPS location error: $e');
      rethrow;
    }
  }

  // Reverse geocode using OpenStreetMap (free, no API key needed)
  static Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        
        return {
          'name': _extractLocationName(address),
          'country': address['country'] ?? 'Unknown',
          'state': address['state'] ?? address['county'],
          'city': address['city'] ?? address['town'] ?? address['village'],
        };
      }
    } catch (e) {
      print('Reverse geocode error: $e');
    }
    
    // Fallback
    return {
      'name': 'Current Location',
      'country': 'Unknown',
    };
  }

  static String _extractLocationName(Map<String, dynamic> address) {
    if (address['city'] != null) return address['city'];
    if (address['town'] != null) return address['town'];
    if (address['village'] != null) return address['village'];
    if (address['county'] != null) return address['county'];
    if (address['state'] != null) return address['state'];
    return 'Current Location';
  }

  // Get saved location
  static Future<Location?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_selectedLocationKey);
      
      if (locationJson != null) {
        final locationMap = Map<String, dynamic>.from(json.decode(locationJson));
        final location = Location.fromJson(locationMap);
        
        // If location is stale, try to refresh it
        if (location.isStale && location.isCurrentLocation) {
          try {
            final freshLocation = await getCurrentLocation();
            await saveLocation(freshLocation);
            return freshLocation;
          } catch (e) {
            // Return stale location if refresh fails
            return location;
          }
        }
        
        return location;
      }
    } catch (e) {
      print('Error loading saved location: $e');
    }
    return null;
  }

  // Save location
  static Future<void> saveLocation(Location location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = json.encode(location.toJson());
      await prefs.setString(_selectedLocationKey, locationJson);
      
      // Also cache this location in recent locations
      await _cacheLocation(location);
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  // Cache recent locations
  static Future<void> _cacheLocation(Location location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedLocationsKey);
      List<Map<String, dynamic>> cachedLocations = [];
      
      if (cachedJson != null) {
        cachedLocations = List<Map<String, dynamic>>.from(json.decode(cachedJson));
      }
      
      // Remove if already exists
      cachedLocations.removeWhere((loc) => loc['id'] == location.id);
      
      // Add to beginning
      cachedLocations.insert(0, location.toJson());
      
      // Keep only last 10 locations
      if (cachedLocations.length > 10) {
        cachedLocations = cachedLocations.sublist(0, 10);
      }
      
      await prefs.setString(_cachedLocationsKey, json.encode(cachedLocations));
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  // Get cached locations
  static Future<List<Location>> getCachedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedLocationsKey);
      
      if (cachedJson != null) {
        final cachedList = List<Map<String, dynamic>>.from(json.decode(cachedJson));
        return cachedList.map((json) => Location.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading cached locations: $e');
    }
    return [];
  }

  // Popular cities in Bangladesh
  static final List<Location> popularLocations = [
    Location(
      id: 'dhaka',
      name: 'Dhaka',
      country: 'Bangladesh',
      state: 'Dhaka Division',
      city: 'Dhaka',
      latitude: 23.8103,
      longitude: 90.4125,
      lastUpdated: DateTime.now(),
    ),
    Location(
      id: 'chittagong',
      name: 'Chittagong',
      country: 'Bangladesh',
      state: 'Chittagong Division',
      city: 'Chittagong',
      latitude: 22.3569,
      longitude: 91.7832,
      lastUpdated: DateTime.now(),
    ),
    Location(
      id: 'khulna',
      name: 'Khulna',
      country: 'Bangladesh',
      state: 'Khulna Division',
      city: 'Khulna',
      latitude: 22.8456,
      longitude: 89.5403,
      lastUpdated: DateTime.now(),
    ),
    Location(
      id: 'barguna',
      name: 'Barguna',
      country: 'Bangladesh',
      state: 'Barisal Division',
      city: 'Barguna',
      latitude: 22.0953,
      longitude: 90.1121,
      lastUpdated: DateTime.now(),
    ),
  ];
}