import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../data/models/timetable_models.dart';
import '../../data/models/attendance_models.dart';
import '../../constants.dart';
import 'class_detail_screen.dart';
import 'package:intl/intl.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StudentProvider>();
      provider.fetchBatchTimetable();
      provider.fetchMyAttendance();
      if (provider.profile?.batch?.id != null) {
        provider.fetchHolidays(batchId: provider.profile!.batch!.id);
      }
    });
  }

  List<TimetableEntry> _generateSchedule(dynamic batch, dynamic student, List<dynamic> attendanceRecords) {
    if (batch == null || batch.startDate == null) return [];

    List<TimetableEntry> schedule = [];
    DateTime now = DateTime.now();
    
    // Start from the batch start date, but for the list view, we might want to focus on recent/future
    DateTime start = batch.startDate!;
    DateTime end = batch.endDate ?? start.add(const Duration(days: 180)); // Default to 6 months if no end date
    
    // To keep the list manageable, let's show from 30 days ago up to batch end
    DateTime viewStart = now.subtract(const Duration(days: 30));
    if (viewStart.isBefore(start)) viewStart = start;

    for (int i = 0; i <= end.difference(viewStart).inDays; i++) {
      DateTime date = viewStart.add(Duration(days: i));
      if (_isWorkingDay(date, batch)) {
        schedule.add(TimetableEntry(
          id: 'v_${date.millisecondsSinceEpoch}',
          batch: batch.id,
          subject: student.course?.name ?? 'Main Class',
          faculty: batch.facultyName ?? 'Faculty',
          date: date,
          startTime: batch.startTime ?? '09:00 AM',
          endTime: batch.endTime ?? '11:00 AM',
          classroom: 'Main Hall',
        ));
      }
    }
    // Changed to chronological order (earliest first) as requested
    return schedule;
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String? _getAttendanceStatus(DateTime date, List<dynamic> records, List<dynamic> holidays) {
    // 1. Check for holiday FIRST (This overrides any attendance records)
    try {
      final holiday = holidays.firstWhere((h) => _isSameDay(h.date, date));
      return 'Leave: ${holiday.reason}';
    } catch (_) {}

    // 2. Only if NOT a holiday, check for attendance records
    try {
      final record = records.firstWhere((r) => _isSameDay(r.date, date));
      return record.status;
    } catch (_) {
      return null;
    }
  }

  bool _isWorkingDay(DateTime date, dynamic batch) {
    String dayName = DateFormat('EEEE').format(date); // Monday, Tuesday...
    String shortDay = DateFormat('E').format(date); // Mon, Tue...

    if (batch.workingDays == 'Daily') return true;
    if (batch.workingDays == 'Monday-Friday') {
      return date.weekday >= 1 && date.weekday <= 5;
    }
    if (batch.workingDays == 'Monday-Saturday') {
      return date.weekday >= 1 && date.weekday <= 6;
    }
    if (batch.workingDays == 'Weekend') {
      return date.weekday == 6 || date.weekday == 7;
    }
    if (batch.workingDays == 'Custom') {
      return batch.customWorkingDays.any((d) => 
        d.toLowerCase().trim() == shortDay.toLowerCase().trim() || 
        d.toLowerCase().trim() == dayName.toLowerCase().trim());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final profile = studentProvider.profile;
    final attendance = studentProvider.myAttendance;
    final holidays = studentProvider.holidays;
    List<TimetableEntry> timetable = studentProvider.batchTimetable;

    // If no explicit timetable, generate from batch schedule
    bool isGenerated = false;
    if (timetable.isEmpty && profile?.batch != null && !studentProvider.isLoading) {
      timetable = _generateSchedule(profile!.batch, profile, attendance);
      isGenerated = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: studentProvider.isLoading && timetable.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : timetable.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (isGenerated)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Automated Schedule from Batch Details',
                              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await studentProvider.fetchBatchTimetable();
                          await studentProvider.fetchMyAttendance();
                          await studentProvider.fetchHolidays(batchId: profile?.batch?.id);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: timetable.length,
                          itemBuilder: (context, index) {
                            final entry = timetable[index];
                            final status = _getAttendanceStatus(entry.date, attendance, holidays);
                            return _buildTimetableCard(entry, status);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No classes scheduled', style: TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTimetableCard(TimetableEntry entry, String? status) {
    final df = DateFormat('EEEE, MMM dd');
    Color statusColor = Colors.grey;
    bool isHoliday = status?.startsWith('Leave:') ?? false;
    String displayStatus = status ?? '';

    // Find the attendance record for this date to get task/desc
    final provider = context.read<StudentProvider>();
    final attRecord = provider.myAttendance.where(
      (r) => _isSameDay(r.date, entry.date),
    ).firstOrNull;

    if (isHoliday) {
      statusColor = Colors.red; // Changed to red for holidays
      displayStatus = status!.replaceFirst('Leave: ', '');
    } else {
      if (status == 'Present') statusColor = Colors.green;
      if (status == 'Absent') statusColor = Colors.red;
      if (status == 'Late') statusColor = Colors.orange;
      if (status == 'Leave') statusColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailScreen(
              entry: entry,
              attendanceRecord: attRecord,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isHoliday ? Colors.red.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Text(entry.startTime, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isHoliday ? Colors.red : Colors.black)),
                Icon(Icons.keyboard_arrow_down, size: 16, color: isHoliday ? Colors.red : AppColors.primary),
                Text(entry.endTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 20),
            Container(width: 1, height: 60, color: isHoliday ? Colors.red.withValues(alpha: 0.2) : AppColors.border),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(entry.subject, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isHoliday ? Colors.red : Colors.black), overflow: TextOverflow.ellipsis),
                      ),
                      if (status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            displayStatus,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(entry.faculty, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(df.format(entry.date), style: TextStyle(fontSize: 12, color: isHoliday ? Colors.red : AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
