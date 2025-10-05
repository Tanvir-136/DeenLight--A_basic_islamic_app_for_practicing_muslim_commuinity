import 'package:flutter/foundation.dart';
import '../services/prayer_time_service.dart';
import '../models/prayer_time.dart';

class PrayerTimeProvider with ChangeNotifier {
  DailyPrayerTimes? _prayerTimes;
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;

  DailyPrayerTimes? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;

  Future<void> loadPrayerTimes({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final times = await PrayerTimeService.getPrayerTimes(forceRefresh: forceRefresh);
      _prayerTimes = times;
      _isOffline = DateTime.now().difference(times.lastUpdated) > Duration(hours: 6);
    } catch (e) {
      _error = 'Failed to load prayer times: $e';
      _isOffline = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshPrayerTimes() {
    loadPrayerTimes(forceRefresh: true);
  }

  // Get next prayer time
  PrayerTime? getNextPrayer() {
    if (_prayerTimes == null) return null;
    
    final now = DateTime.now();
    final upcomingPrayers = _prayerTimes!.prayerTimes
        .where((prayer) => prayer.dateTime.isAfter(now))
        .toList();
    
    return upcomingPrayers.isNotEmpty ? upcomingPrayers.first : null;
  }
}