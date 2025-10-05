import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TasbeehScreenState createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _counter = 0;
  final List<String> _tasbeehList = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله'
  ];
  int _currentTasbeehIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter >= 33) {
        _counter = 0;
        _currentTasbeehIndex = (_currentTasbeehIndex + 1) % _tasbeehList.length;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('tasbeeh')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _tasbeehList[_currentTasbeehIndex],
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40.0),
            Text(
              '$_counter',
              style: TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: Text('Count', style: TextStyle(fontSize: 20.0)),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _resetCounter,
              child: Text('Reset', style: TextStyle(fontSize: 20.0)),
            ),
          ],
        ),
      ),
    );
  }
}