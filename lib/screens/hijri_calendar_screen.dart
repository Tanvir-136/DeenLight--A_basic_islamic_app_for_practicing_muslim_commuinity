import 'package:flutter/material.dart';
import '../services/hijri_api_service.dart';
import '../models/hijri_calender.dart';
import '../localization/app_localizations.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  HijriCalendar? _hijriData;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHijriDate();
  }

  Future<void> _loadHijriDate() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await HijriApiService.getHijriDate();
      setState(() => _hijriData = data);
    } catch (e) {
      // Error handled in UI
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('hijriCalendar')),
        actions: [
          IconButton(
            icon: _isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadHijriDate,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hijriData == null
              ? _buildErrorState()
              : _buildResponsiveCalendar(_hijriData!, isSmallScreen, isLargeScreen),
    );
  }

  Widget _buildResponsiveCalendar(HijriCalendar data, bool isSmallScreen, bool isLargeScreen) {
    return Column(
      children: [
        // Flexible Month Header
        _buildMonthHeader(data, isSmallScreen),
        
        // Flexible Weekday Headers
        _buildWeekdayHeaders(isSmallScreen, isLargeScreen),
        
        // Flexible Calendar Grid
        Expanded(
          child: _buildFlexibleCalendarGrid(data.monthlyCalendar!, isSmallScreen, isLargeScreen),
        ),
        
        // Flexible Current Date Info
        _buildCurrentDateInfo(data, isSmallScreen),
      ],
    );
  }

  Widget _buildMonthHeader(HijriCalendar data, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 20,
        vertical: isSmallScreen ? 12 : 16,
      ),
      color: Colors.green[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.hijriMonth} ${data.hijriYear} AH',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  'Hijri Calendar',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          if (data.holiday != 'No holiday')
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Special',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(bool isSmallScreen, bool isLargeScreen) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Text(
              isSmallScreen ? day.substring(0, 1) : day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: day == 'Fri' ? Colors.green : Colors.grey[700],
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlexibleCalendarGrid(List<HijriDay> calendar, bool isSmallScreen, bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final cellSize = _calculateCellSize(availableHeight, isSmallScreen, isLargeScreen);
        
        return GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: isSmallScreen ? 4 : 8,
            mainAxisSpacing: isSmallScreen ? 4 : 8,
            childAspectRatio: 1.0,
          ),
          itemCount: calendar.length,
          itemBuilder: (context, index) {
            final day = calendar[index];
            return _buildFlexibleDayCell(day, cellSize, isSmallScreen, isLargeScreen);
          },
        );
      },
    );
  }

  Widget _buildFlexibleDayCell(HijriDay day, double cellSize, bool isSmallScreen, bool isLargeScreen) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: day.isToday ? Colors.green[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
        border: Border.all(
          color: day.isToday ? Colors.green : Colors.grey[300]!,
          width: day.isToday ? (isSmallScreen ? 1.5 : 2) : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hijri Day Number
          Text(
            '${day.day}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: day.isHoliday ? Colors.red : Colors.green[800],
              fontSize: _getDayFontSize(cellSize, isSmallScreen),
            ),
          ),
          
          // Gregorian equivalent - only show on larger screens
          if (!isSmallScreen)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _getGregorianDay(day.gregorianDate),
                style: TextStyle(
                  fontSize: _getGregorianFontSize(cellSize),
                  color: Colors.grey[600],
                ),
              ),
            ),
          
          // Holiday indicator
          if (day.isHoliday)
            Container(
              margin: EdgeInsets.only(top: isSmallScreen ? 1 : 2),
              width: _getHolidayDotSize(cellSize),
              height: _getHolidayDotSize(cellSize),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentDateInfo(HijriCalendar data, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(top: BorderSide(color: Colors.green[100]!)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline, 
            color: Colors.green[600],
            size: isSmallScreen ? 18 : 24,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today: ${data.hijriDate}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green[800],
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (data.holiday != 'No holiday')
                  Padding(
                    padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
                    child: Text(
                      data.holiday,
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for responsive sizing
  double _calculateCellSize(double availableHeight, bool isSmallScreen, bool isLargeScreen) {
    final baseSize = isSmallScreen ? 36.0 : isLargeScreen ? 60.0 : 48.0;
    final maxRows = 6; // Maximum rows in calendar
    final calculatedSize = (availableHeight - (isSmallScreen ? 64 : 96)) / maxRows;
    
    return calculatedSize.clamp(baseSize * 0.8, baseSize * 1.5);
  }

  double _getDayFontSize(double cellSize, bool isSmallScreen) {
    final baseSize = isSmallScreen ? 12.0 : 14.0;
    return (cellSize * 0.3).clamp(baseSize, baseSize * 1.5);
  }

  double _getGregorianFontSize(double cellSize) {
    return (cellSize * 0.2).clamp(8.0, 12.0);
  }

  double _getHolidayDotSize(double cellSize) {
    return (cellSize * 0.15).clamp(4.0, 8.0);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Failed to load calendar',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadHijriDate,
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _getGregorianDay(String gregorianDate) {
    try {
      return gregorianDate.split('/')[0];
    } catch (e) {
      return '?';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}