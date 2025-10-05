import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hijri_calender.dart';

class HijriApiService {
  static const String _baseUrl = 'http://api.aladhan.com/v1/gToH';
  
  static Future<HijriCalendar> getHijriDate() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final hijriData = HijriCalendar.fromJson(jsonData['data']);
        
        // Generate monthly calendar
        final monthlyCalendar = _generateMonthlyCalendar(hijriData);
        
        return HijriCalendar(
          date: hijriData.date,
          hijriDate: hijriData.hijriDate,
          hijriMonth: hijriData.hijriMonth,
          hijriYear: hijriData.hijriYear,
          holiday: hijriData.holiday,
          monthlyCalendar: monthlyCalendar,
        );
      } else {
        throw Exception('Failed to load Hijri date');
      }
    } catch (e) {
      // Return fallback with generated calendar
      final now = DateTime.now();
      final fallback = HijriCalendar(
        date: now.toString(),
        hijriDate: '${now.day} ${_getMonthName(now.month)} ${now.year}',
        hijriMonth: _getMonthName(now.month),
        hijriYear: now.year.toString(),
        holiday: 'No holiday information available',
        monthlyCalendar: _generateFallbackCalendar(),
      );
      return fallback;
    }
  }

  static List<HijriDay> _generateMonthlyCalendar(HijriCalendar hijriData) {
    final List<HijriDay> calendar = [];
    final now = DateTime.now();
    
    // Generate 30 days for Hijri month (Hijri months are 29-30 days)
    for (int day = 1; day <= 30; day++) {
      final isToday = day == now.day; // Simple approximation
      final isHoliday = day == 1 || day == 10 || day == 27; // Example holidays
      
      calendar.add(HijriDay(
        day: day,
        hijriDate: '$day ${hijriData.hijriMonth} ${hijriData.hijriYear} AH',
        gregorianDate: _calculateGregorianDate(day, hijriData),
        isToday: isToday,
        isHoliday: isHoliday,
        holidayName: isHoliday ? _getHolidayName(day) : null,
      ));
    }
    
    return calendar;
  }

  static List<HijriDay> _generateFallbackCalendar() {
    final List<HijriDay> calendar = [];
    final now = DateTime.now();
    
    for (int day = 1; day <= 30; day++) {
      calendar.add(HijriDay(
        day: day,
        hijriDate: '$day Month ${now.year} AH',
        gregorianDate: '${now.day + day - 1}/${now.month}/${now.year}',
        isToday: day == now.day,
        isHoliday: false,
      ));
    }
    
    return calendar;
  }

  static String _calculateGregorianDate(int hijriDay, HijriCalendar hijriData) {
    // Simplified calculation - in real app, use proper conversion
    final now = DateTime.now();
    return '${now.day + hijriDay - 1}/${now.month}/${now.year}';
  }

  static String _getHolidayName(int day) {
    switch (day) {
      case 1: return 'Islamic New Year';
      case 10: return 'Ashura';
      case 27: return 'Laylat al-Qadr';
      default: return 'Special Day';
    }
  }

  static String _getMonthName(int month) {
    final months = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
    return months[month - 1];
  }
}