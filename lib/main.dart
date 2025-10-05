import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'localization/app_localizations.dart';
import 'screens/home_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/prayer_time_provider.dart';
import 'providers/location_provider.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()), // Add this line
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Islamic Practices',
            theme: settingsProvider.settings.isDarkMode
                ? ThemeData.dark().copyWith(
                    primaryColor: Colors.green,
                    colorScheme: ColorScheme.fromSwatch(
                      primarySwatch: Colors.green,
                      brightness: Brightness.dark,
                    ),
                  )
                : ThemeData(
                    primarySwatch: Colors.green,
                  ),
            locale: Locale(settingsProvider.settings.languageCode),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''),
              Locale('bn', ''),
            ],
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}