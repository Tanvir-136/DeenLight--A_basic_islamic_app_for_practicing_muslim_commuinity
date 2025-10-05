import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/prayer_time_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerTimeProvider>().loadPrayerTimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();

    return Scaffold(
      appBar: AppBar(
        title:Text(AppLocalizations.of(context).translate('prayerTimes')),
        actions: [
          if (provider.isOffline)
            Icon(Icons.wifi_off, color: Colors.orange),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : () => provider.refreshPrayerTimes(),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PrayerTimeProvider provider) {
    if (provider.isLoading && provider.prayerTimes == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.prayerTimes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.loadPrayerTimes(),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    final prayerTimes = provider.prayerTimes!;
    final nextPrayer = provider.getNextPrayer();

    return Column(
      children: [
        // Header with date and offline indicator
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Colors.green[50],
          child: Column(
            children: [
              Text(
                prayerTimes.date,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(prayerTimes.hijriDate),
              if (provider.isOffline) ...[
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'Offline - Last updated: ${_formatTime(prayerTimes.lastUpdated)}',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Next prayer card
        if (nextPrayer != null)
          Card(
            margin: EdgeInsets.all(16),
            color: Colors.green[100],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Next Prayer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    nextPrayer.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    nextPrayer.time,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),

        // Prayer times list
        Expanded(
          child: ListView.builder(
            itemCount: prayerTimes.prayerTimes.length,
            itemBuilder: (context, index) {
              final prayer = prayerTimes.prayerTimes[index];
              return ListTile(
                leading: prayer.isPassed
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.access_time, color: Colors.blue),
                title: Text(prayer.name),
                trailing: Text(
                  prayer.time,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: prayer.isPassed ? Colors.grey : Colors.black,
                  ),
                ),
                tileColor: prayer.isPassed ? Colors.grey[100] : null,
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}