class AppSettings {
  final String languageCode;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String notificationTime;

  AppSettings({
    required this.languageCode,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.notificationTime,
  });

  AppSettings copyWith({
    String? languageCode,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? notificationTime,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }
}