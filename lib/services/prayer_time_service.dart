import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/prayer_time.dart';

class PrayerTimeService {
  static const String _cacheKey = 'prayer_times_cache';
  static const String _cacheDateKey = 'prayer_times_cache_date';
  static const Duration _cacheDuration = Duration(hours: 6); // Update every 6 hours

  // Get prayer times with cache-first strategy
  static Future<DailyPrayerTimes> getPrayerTimes({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();
    final bool isOnline = connectivityResult != ConnectivityResult.none;

    // Check if we have cached data and it's not expired
    if (!forceRefresh) {
      final cachedData = _getCachedData(prefs);
      if (cachedData != null && !_isCacheExpired(cachedData.lastUpdated)) {
        return cachedData;
      }
    }

    // If online, try to fetch new data
    if (isOnline) {
      try {
        final newData = await _fetchFromAPI();
        await _cacheData(prefs, newData);
        return newData;
      } catch (e) {
        print('API fetch failed: $e');
        // Fall back to cache even if expired
        final cachedData = _getCachedData(prefs);
        if (cachedData != null) {
          return cachedData;
        }
      }
    }

    // If offline or API failed, try to get cached data (even expired)
    final cachedData = _getCachedData(prefs);
    if (cachedData != null) {
      return cachedData;
    }

    // If no cache available, return default times
    return _getDefaultPrayerTimes();
  }

  static DailyPrayerTimes? _getCachedData(SharedPreferences prefs) {
    try {
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final jsonData = json.decode(cachedJson);
        return DailyPrayerTimes.fromJson(jsonData);
      }
    } catch (e) {
      print('Error reading cache: $e');
    }
    return null;
  }

  static Future<void> _cacheData(SharedPreferences prefs, DailyPrayerTimes data) async {
    try {
      final jsonString = json.encode(data.toJson());
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setString(_cacheDateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  static bool _isCacheExpired(DateTime lastUpdated) {
    return DateTime.now().difference(lastUpdated) > _cacheDuration;
  }

  static Future<DailyPrayerTimes> _fetchFromAPI() async {
    // Using Aladhan API - you can change to any prayer time API
    final response = await http.get(Uri.parse(
      'http://api.aladhan.com/v1/timingsByCity?city=Dhaka&country=Bangladesh&method=1'
    ));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return _parseApiResponse(jsonData);
    } else {
      throw Exception('Failed to load prayer times: ${response.statusCode}');
    }
  }

  static DailyPrayerTimes _parseApiResponse(Map<String, dynamic> jsonData) {
    final timings = jsonData['data']['timings'];
    final date = jsonData['data']['date']['readable'];
    final hijriDate = jsonData['data']['date']['hijri']['date'];

    final prayerTimes = [
      PrayerTime(
        name: 'Fajr',
        time: timings['Fajr'],
        dateTime: _parseTimeString(timings['Fajr']),
        isPassed: _isTimePassed(timings['Fajr']),
      ),
      PrayerTime(
        name: 'Dhuhr',
        time: timings['Dhuhr'],
        dateTime: _parseTimeString(timings['Dhuhr']),
        isPassed: _isTimePassed(timings['Dhuhr']),
      ),
      PrayerTime(
        name: 'Asr',
        time: timings['Asr'],
        dateTime: _parseTimeString(timings['Asr']),
        isPassed: _isTimePassed(timings['Asr']),
      ),
      PrayerTime(
        name: 'Maghrib',
        time: timings['Maghrib'],
        dateTime: _parseTimeString(timings['Maghrib']),
        isPassed: _isTimePassed(timings['Maghrib']),
      ),
      PrayerTime(
        name: 'Isha',
        time: timings['Isha'],
        dateTime: _parseTimeString(timings['Isha']),
        isPassed: _isTimePassed(timings['Isha']),
      ),
    ];

    return DailyPrayerTimes(
      date: date,
      hijriDate: hijriDate,
      prayerTimes: prayerTimes,
      lastUpdated: DateTime.now(),
    );
  }

  static DateTime _parseTimeString(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    return DateTime(now.year, now.month, now.day, 
        int.parse(parts[0]), int.parse(parts[1]));
  }

  static bool _isTimePassed(String time) {
    final prayerTime = _parseTimeString(time);
    return DateTime.now().isAfter(prayerTime);
  }

  static DailyPrayerTimes _getDefaultPrayerTimes() {
    final now = DateTime.now();
    return DailyPrayerTimes(
      date: '${now.day}/${now.month}/${now.year}',
      hijriDate: 'Default Date',
      prayerTimes: [
        PrayerTime(name: 'Fajr', time: '05:00', dateTime: now, isPassed: false),
        PrayerTime(name: 'Dhuhr', time: '12:00', dateTime: now, isPassed: false),
        PrayerTime(name: 'Asr', time: '15:30', dateTime: now, isPassed: false),
        PrayerTime(name: 'Maghrib', time: '18:00', dateTime: now, isPassed: false),
        PrayerTime(name: 'Isha', time: '19:30', dateTime: now, isPassed: false),
      ],
      lastUpdated: now,
    );
  }
}