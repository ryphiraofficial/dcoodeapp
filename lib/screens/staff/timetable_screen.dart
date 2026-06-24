import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'add_timetable_screen.dart';
import 'daily_timetable_screen.dart';

class StaffTimetableScreen extends StatefulWidget {
  const StaffTimetableScreen({super.key});

  @override
  State<StaffTimetableScreen> createState() => _StaffTimetableScreenState();
}

class _StaffTimetableScreenState extends State<StaffTimetableScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // We could fetch monthly events here to show markers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildCalendar(),
            const SizedBox(height: 20),
            _buildInstructions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTimetableScreen()),
          );
          if (result == true) {
             // Refresh logic if needed
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          // Navigate to daily view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyTimetableScreen(selectedDate: selectedDay),
            ),
          );
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          formatButtonTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          todayTextStyle: const TextStyle(color: Colors.black),
          markersMaxCount: 1,
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Select a date to view or manage the academic schedule for that day.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
