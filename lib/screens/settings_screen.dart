import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';
import '../localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings')),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'language_settings'),
          _buildLanguageSetting(context, settingsProvider, settings),
          
          SizedBox(height: 24.0),
          _buildSectionTitle(context, 'appearance_settings'),
          _buildDarkModeSetting(context, settingsProvider, settings),
          
          SizedBox(height: 24.0),
          _buildSectionTitle(context, 'notification_settings'),
          _buildNotificationSetting(context, settingsProvider, settings),
          if (settings.notificationsEnabled)
            _buildNotificationTimeSetting(context, settingsProvider, settings),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    return Text(
      AppLocalizations.of(context).translate(titleKey),
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context, SettingsProvider provider, AppSettings settings) {
    return ListTile(
      leading: Icon(Icons.language),
      title: Text(AppLocalizations.of(context).translate('language')),
      subtitle: Text(settings.languageCode == 'bn' ? 'বাংলা' : 'English'),
      onTap: () {
        _showLanguageDialog(context, provider);
      },
    );
  }

  Widget _buildDarkModeSetting(BuildContext context, SettingsProvider provider, AppSettings settings) {
    return SwitchListTile(
      secondary: Icon(Icons.dark_mode),
      title: Text(AppLocalizations.of(context).translate('dark_mode')),
      value: settings.isDarkMode,
      onChanged: (value) {
        provider.toggleDarkMode();
      },
    );
  }

  Widget _buildNotificationSetting(BuildContext context, SettingsProvider provider, AppSettings settings) {
    return SwitchListTile(
      secondary: Icon(Icons.notifications),
      title: Text(AppLocalizations.of(context).translate('notifications')),
      value: settings.notificationsEnabled,
      onChanged: (value) {
        provider.toggleNotifications(value);
      },
    );
  }

  Widget _buildNotificationTimeSetting(BuildContext context, SettingsProvider provider, AppSettings settings) {
    return ListTile(
      leading: Icon(Icons.access_time),
      title: Text(AppLocalizations.of(context).translate('notification_time')),
      subtitle: Text(settings.notificationTime),
      onTap: () {
        _selectTime(context, provider);
      },
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  provider.changeLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('বাংলা'),
                onTap: () {
                  provider.changeLanguage('bn');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, SettingsProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      final time = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      provider.changeNotificationTime(time);
    }
  }
}