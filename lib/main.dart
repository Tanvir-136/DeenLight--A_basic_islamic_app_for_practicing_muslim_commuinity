import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(IslamicPracticesApp());
}

class IslamicPracticesApp extends StatelessWidget {
  const IslamicPracticesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Islamic Practices',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        fontFamily: 'Nunito',
      ),
      home: MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    HijriCalendarScreen(),
    TasbeehScreen(),
    DuasScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            iconSize: 28,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Hijri',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Tasbeeh',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Duas',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------- Home Screen ---------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime now = DateTime.now();
  Timer? _timer;
  bool _isLoading = true;
  String _errorMessage = '';

  // Prayer times data
  final List<Map<String, dynamic>> prayerTimes = [];

  DateTime _nextPrayerTime = DateTime.now().add(Duration(hours: 1));
  String _nextPrayerName = 'Loading...';
  Duration _timeUntilNext = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
  }

  // Fetch prayer times from API
  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current date
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // API call to Aladhan (Islamic Prayer Times API)
      final response = await http.get(
        Uri.parse('https://api.aladhan.com/v1/timings/$formattedDate?latitude=40.7128&longitude=-74.0060&method=2')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        
        // Clear existing prayer times
        prayerTimes.clear();
        
        // Add prayer times with proper DateTime objects
        prayerTimes.addAll([
          {'name': 'Fajr', 'time': _parsePrayerTime(timings['Fajr'])},
          {'name': 'Dhuhr', 'time': _parsePrayerTime(timings['Dhuhr'])},
          {'name': 'Asr', 'time': _parsePrayerTime(timings['Asr'])},
          {'name': 'Maghrib', 'time': _parsePrayerTime(timings['Maghrib'])},
          {'name': 'Isha', 'time': _parsePrayerTime(timings['Isha'])},
        ]);
        
        _computeNextPrayer();
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load prayer times. Using sample data.';
        _generateMockPrayerTimes();
        _computeNextPrayer();
      });
    }
  }

  // Parse time string (e.g., "05:30") to DateTime
  DateTime _parsePrayerTime(String timeStr) {
    final today = DateTime.now();
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(today.year, today.month, today.day, hour, minute);
  }

  void _generateMockPrayerTimes() {
    final today = DateTime.now();
    prayerTimes.clear();
    prayerTimes.addAll([
      {'name': 'Fajr', 'time': DateTime(today.year, today.month, today.day, 5, 0)},
      {'name': 'Dhuhr', 'time': DateTime(today.year, today.month, today.day, 12, 30)},
      {'name': 'Asr', 'time': DateTime(today.year, today.month, today.day, 16, 0)},
      {'name': 'Maghrib', 'time': DateTime(today.year, today.month, today.day, 18, 15)},
      {'name': 'Isha', 'time': DateTime(today.year, today.month, today.day, 19, 45)},
    ]);
  }

  void _computeNextPrayer() {
    final now = DateTime.now();
    for (var p in prayerTimes) {
      if (p['time'].isAfter(now)) {
        _nextPrayerTime = p['time'];
        _nextPrayerName = p['name'];
        break;
      }
    }
    // if all past -> next day fajr
    if (!_nextPrayerTime.isAfter(now)) {
      final tomorrow = now.add(Duration(days: 1));
      _nextPrayerTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0);
      _nextPrayerName = 'Fajr';
    }
    _timeUntilNext = _nextPrayerTime.difference(now);
  }

  void _tick() {
    setState(() {
      now = DateTime.now();
      _timeUntilNext = _nextPrayerTime.difference(now);
      if (_timeUntilNext.isNegative) {
        _fetchPrayerTimes();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assalamu Alaikum', 
                style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('12 Muharram 1447', 
                style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: Icon(Icons.search, color: Colors.deepPurple, size: 28),
            iconSize: 28,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple[100],
              child: Icon(Icons.person, color: Colors.deepPurple),
            ),
          ),
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(child: Text(_errorMessage)),
                        ],
                      ),
                    ),
                  
                  // Next Prayer Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.deepPurple, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withAlpha((0.3 * 255).toInt()),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Next Prayer', 
                                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                                SizedBox(height: 8),
                                Text(_nextPrayerName, 
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                SizedBox(height: 8),
                                Text('In ${_formatDuration(_timeUntilNext)}', 
                                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.2 * 255).toInt()),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.access_time, size: 36, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Prayer Times Section
                  Text('Prayer Times Today', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final p = prayerTimes[index];
                        final timeStr = _timeStringFromDateTime(p['time']);
                        final isActive = p['name'] == _nextPrayerName;
                        return _PrayerCard(
                          name: p['name'], 
                          time: timeStr,
                          isActive: isActive,
                        );
                      },
                      separatorBuilder: (_, __) => SizedBox(width: 16),
                      itemCount: prayerTimes.length,
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Daily Dua Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Dua', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {}, 
                        child: Text('See all', style: TextStyle(color: Colors.deepPurple)),
                      )
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  _DuaCard(
                    title: 'Dua for traveling',
                    content: 'A short dua for safe travel',
                    icon: Icons.directions_car,
                  ),
                  
                  SizedBox(height: 12),
                  
                  _DuaCard(
                    title: 'Dua before sleeping',
                    content: 'Short supplication before sleep',
                    icon: Icons.bedtime,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Quick Access Buttons
                  Text('Quick Access', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickActionButton(
                        icon: Icons.water_drop,
                        label: 'Ablution',
                        onTap: () {},
                      ),
                      _QuickActionButton(
                        icon: Icons.auto_stories,
                        label: 'Qibla',
                        onTap: () {},
                      ),
                      _QuickActionButton(
                        icon: Icons.volume_up,
                        label: 'Azan',
                        onTap: () {},
                      ),
                      _QuickActionButton(
                        icon: Icons.settings,
                        label: 'Settings',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _timeStringFromDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final String time;
  final bool isActive;
  
  const _PrayerCard({
    required this.name, 
    required this.time, 
    this.isActive = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurple : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, 
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 16
              )),
          SizedBox(height: 8),
          Text(time, 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.black87,
              )),
          SizedBox(height: 8),
          Icon(
            Icons.light_mode, 
            size: 18, 
            color: isActive ? Colors.white : Colors.orange
          ),
        ],
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  
  const _DuaCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Empty function
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.deepPurple),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text(content, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// --------------------------- Hijri Calendar Screen ---------------------------
class HijriCalendarScreen extends StatelessWidget {
  final List<int> days = List.generate(30, (i) => i + 1);

  HijriCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Hijri Calendar', 
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Muharram 1447', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 6),
                      Text('Gregorian: Aug 20, 2025', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Add event', style: TextStyle(fontSize: 14)),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, 
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: days.length + 7,
                itemBuilder: (context, index) {
                  if (index < 7) {
                    List<String> dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        dayHeaders[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  }
                  
                  final d = days[index - 7];
                  final isToday = d == DateTime.now().day;
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: isToday ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          d.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --------------------------- Tasbeeh Screen ---------------------------
class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  _TasbeehScreenState createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _count = 0;
  int _target = 33;

  void _increment() => setState(() => _count++);
  void _decrement() => setState(() { if (_count>0) _count--; });
  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Tasbeeh Counter', 
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_count',
                        style: TextStyle(
                          fontSize: 48, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Target: $_target', 
                        style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _decrement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove, size: 20),
                      SizedBox(width: 4),
                      Text('Minus', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _increment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 4),
                      Text('Add', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Reset', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Target:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Slider(
                    value: _target.toDouble(),
                    min: 1,
                    max: 500,
                    divisions: 499,
                    label: '$_target',
                    onChanged: (v) => setState(() => _target = v.toInt()),
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --------------------------- Duas Screen ---------------------------
class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  _DuasScreenState createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  final List<Map<String, String>> duas = [
    {'title': 'Dua for entering mosque', 'content': 'Allahumma ftah li abwaba rahmatik...'},
    {'title': 'Dua for leaving home', 'content': 'Bismillah, tawakkaltu ala Allah...'},
    {'title': 'Dua for travel', 'content': 'Subhanalladhi sakhkhara lana...'},
    {'title': 'Dua after prayer', 'content': 'Astaghfirullah, Astaghfirullah, Astaghfirullah...'},
    {'title': 'Dua for parents', 'content': 'Rabbighfir li waliwalidayya...'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Daily Duas', 
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final d = duas[index];
          return GestureDetector(
            onTap: () {
              // Empty function
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.book, color: Colors.deepPurple),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(d['title']!, 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemCount: duas.length,
      ),
    );
  }
}