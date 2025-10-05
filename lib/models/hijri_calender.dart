class HijriCalendar {
  final String date;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;
  final String holiday;
  final List<HijriDay>? monthlyCalendar;

  HijriCalendar({
    required this.date,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.holiday,
    this.monthlyCalendar,
  });

  factory HijriCalendar.fromJson(Map<String, dynamic> json) {
    return HijriCalendar(
      date: json['date'] ?? '',
      hijriDate: json['hijri']['date'] ?? '',
      hijriMonth: json['hijri']['month']['en'] ?? '',
      hijriYear: json['hijri']['year'] ?? '',
      holiday: json['hijri']['holiday'] ?? 'No holiday',
    );
  }
}

class HijriDay {
  final int day;
  final String hijriDate;
  final String gregorianDate;
  final bool isToday;
  final bool isHoliday;
  final String? holidayName;

  HijriDay({
    required this.day,
    required this.hijriDate,
    required this.gregorianDate,
    required this.isToday,
    required this.isHoliday,
    this.holidayName,
  });
}