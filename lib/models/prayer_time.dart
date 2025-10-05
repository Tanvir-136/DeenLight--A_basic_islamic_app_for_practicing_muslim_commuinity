class PrayerTime {
  final String name;
  final String time;
  final DateTime dateTime;
  final bool isPassed;

  PrayerTime({
    required this.name,
    required this.time,
    required this.dateTime,
    required this.isPassed,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'dateTime': dateTime.toIso8601String(),
      'isPassed': isPassed,
    };
  }

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: json['name'],
      time: json['time'],
      dateTime: DateTime.parse(json['dateTime']),
      isPassed: json['isPassed'],
    );
  }
}

class DailyPrayerTimes {
  final String date;
  final String hijriDate;
  final List<PrayerTime> prayerTimes;
  final DateTime lastUpdated;

  DailyPrayerTimes({
    required this.date,
    required this.hijriDate,
    required this.prayerTimes,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'hijriDate': hijriDate,
      'prayerTimes': prayerTimes.map((time) => time.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    return DailyPrayerTimes(
      date: json['date'],
      hijriDate: json['hijriDate'],
      prayerTimes: (json['prayerTimes'] as List)
          .map((time) => PrayerTime.fromJson(time))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}