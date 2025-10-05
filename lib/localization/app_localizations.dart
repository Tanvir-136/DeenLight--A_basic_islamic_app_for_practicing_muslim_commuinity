import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Islamic Practices',
      'prayerTimes': 'Prayer Times',
      'tasbeeh': 'Tasbeeh',
      'dua': 'Dua',
      'hijriCalendar': 'Hijri Calendar',
      'qibla': 'Qibla Direction',
      'settings': 'Settings',
      // settings_part
      'language_settings': 'Language Settings',
      'appearance_settings': 'Appearance',
      'notification_settings': 'Notifications',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'notifications': 'Enable Notifications',
      'notification_time': 'Notification Time',
      'select_language': 'Select Language',

      //hijri calender
      'todayDate': 'Today\'s Date',
      'hijriDate': 'Hijri Date',
      'specialOccasion': 'Special Occasion',
      'refresh': 'Refresh',
    },
    'bn': {
      'appTitle': 'ইসলামিক প্রাকটিস',
      'prayerTimes': 'নামাজের সময়সূচী',
      'tasbeeh': 'তাসবীহ',
      'dua': 'দোয়া',
      'hijriCalendar': 'হিজরি ক্যালেন্ডার',
      'qibla': 'কিবলা দিক',
      'settings': 'সেটিংস',

      //settings part
      'language_settings': 'ভাষা সেটিংস',
      'appearance_settings': 'অ্যাপের রূপ',
      'notification_settings': 'নোটিফিকেশন',
      'language': 'ভাষা',
      'dark_mode': 'ডার্ক মোড',
      'notifications': 'নোটিফিকেশন সক্রিয় করুন',
      'notification_time': 'নোটিফিকেশন সময়',
      'select_language': 'ভাষা নির্বাচন করুন',

      // hijri calender
      'todayDate': 'আজকের তারিখ',
      'hijriDate': 'হিজরি তারিখ',
      'specialOccasion': 'বিশেষ উপলক্ষ',
      'refresh': 'রিফ্রেশ',
    },
  };

  String? get prayerTimes => null;
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]![key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Return a Future.value instead of SynchronousFuture
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}