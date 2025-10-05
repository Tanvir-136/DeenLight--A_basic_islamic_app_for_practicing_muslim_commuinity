import 'package:flutter/material.dart';
import '../models/settings.dart';

class SettingsProvider with ChangeNotifier {
  AppSettings _settings = AppSettings(
    languageCode: 'bn',
    isDarkMode: false,
    notificationsEnabled: true,
    notificationTime: '00:00',
  );

  AppSettings get settings => _settings;

  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _settings = _settings.copyWith(languageCode: languageCode);
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    notifyListeners();
  }

  void toggleNotifications(bool enabled) {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    notifyListeners();
  }

  void changeNotificationTime(String time) {
    _settings = _settings.copyWith(notificationTime: time);
    notifyListeners();
  }
}