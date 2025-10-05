import 'package:flutter/foundation.dart';
import '../services/location_service.dart';
import '../models/location.dart';

class LocationProvider with ChangeNotifier {
  Location? _currentLocation;
  bool _isLoading = true;
  bool _isGettingLocation = false;
  String? _error;
  List<Location> _availableLocations = [];

  Location? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  bool get isGettingLocation => _isGettingLocation;
  String? get error => _error;
  List<Location> get availableLocations => _availableLocations;

  Future<void> initializeLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load saved location first
      final savedLocation = await LocationService.getSavedLocation();
      
      if (savedLocation != null) {
        _currentLocation = savedLocation;
      } else {
        // If no saved location, use a default
        _currentLocation = LocationService.popularLocations.first;
        await LocationService.saveLocation(_currentLocation!);
      }
      
      // Load available locations
      await _loadAvailableLocations();
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load location';
      _currentLocation = LocationService.popularLocations.first;
      _availableLocations = LocationService.popularLocations;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAvailableLocations() async {
    try {
      final cachedLocations = await LocationService.getCachedLocations();
      final allLocations = [
        ...cachedLocations,
        ...LocationService.popularLocations,
      ];
      
      // Remove duplicates
      final uniqueLocations = <String, Location>{};
      for (final location in allLocations) {
        uniqueLocations[location.id] = location;
      }
      
      _availableLocations = uniqueLocations.values.toList();
    } catch (e) {
      _availableLocations = LocationService.popularLocations;
    }
  }

  Future<void> getCurrentLocation() async {
    _isGettingLocation = true;
    _error = null;
    notifyListeners();

    try {
      final location = await LocationService.getCurrentLocation();
      await _setLocation(location);
      await _loadAvailableLocations(); // Refresh available locations
    } catch (e) {
      _error = 'Failed to get current location: $e';
    } finally {
      _isGettingLocation = false;
      notifyListeners();
    }
  }

  Future<void> changeLocation(Location newLocation) async {
    await _setLocation(newLocation);
  }

  Future<void> _setLocation(Location location) async {
    _currentLocation = location;
    await LocationService.saveLocation(location);
    _error = null;
    notifyListeners();
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}